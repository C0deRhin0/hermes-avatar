#!/usr/bin/env python3
"""Ad-hoc verifier for the Knowledge Base Hermes integration.

Run from any cwd on the operator's VPS:

    python3 ~/.hermes/skills/research/knowledge-base-retrieval/scripts/verify_knowledge_base_integration.py

This is focused verification for the default-profile Knowledge Base plugin/tool/hook,
not a canonical full Hermes or Knowledge Base test suite.
"""

from __future__ import annotations

import json
import os
import pathlib
import py_compile
import subprocess
import sys

ROOT = pathlib.Path("${HOME}/.hermes/hermes-agent")
PLUGIN_DIR = pathlib.Path("${HOME}/.hermes/plugins/knowledge-base-retrieval")
WIKI_ROOT = pathlib.Path("${WORKSPACE_ROOT}/hermes-memory-wiki")
CHANGED_BEHAVIOR_PATHS = [
    pathlib.Path("${HOME}/.hermes/HERMES_CONFIG_CHANGELOG.md"),
    pathlib.Path("${HOME}/.hermes/HERMES_USAGE_GUIDES.md"),
    PLUGIN_DIR / "__init__.py",
    PLUGIN_DIR / "plugin.yaml",
    WIKI_ROOT / "README.md",
    WIKI_ROOT / "KNOWLEDGE_BASE_SPEC.md",
]

checks: list[dict[str, object]] = []


def check(name: str, condition: bool, detail: object = "") -> None:
    checks.append({"name": name, "ok": bool(condition), "detail": str(detail)[:500]})
    if not condition:
        raise AssertionError(f"{name}: {detail}")


def main() -> int:
    for path in CHANGED_BEHAVIOR_PATHS:
        check(f"path exists: {path}", path.exists(), path)

    py_compile.compile(str(PLUGIN_DIR / "__init__.py"), doraise=True)
    check("plugin python compiles", True, PLUGIN_DIR / "__init__.py")

    manifest = (PLUGIN_DIR / "plugin.yaml").read_text(encoding="utf-8")
    for marker in ["knowledge_base_query", "pre_llm_call", "provides_tools", "provides_hooks"]:
        check(f"plugin manifest contains {marker}", marker in manifest)

    for path in [
        pathlib.Path("${HOME}/.hermes/HERMES_USAGE_GUIDES.md"),
        pathlib.Path("${HOME}/.hermes/HERMES_CONFIG_CHANGELOG.md"),
        WIKI_ROOT / "README.md",
        WIKI_ROOT / "KNOWLEDGE_BASE_SPEC.md",
    ]:
        text = path.read_text(encoding="utf-8")
        check(f"{path.name} documents knowledge_base_query", "knowledge_base_query" in text, path)
        check(
            f"{path.name} documents passive/semi-passive behavior",
            "passive" in text.lower() or "semi-passive" in text.lower(),
            path,
        )

    import yaml

    cfg = yaml.safe_load(pathlib.Path("${HOME}/.hermes/config.yaml").read_text(encoding="utf-8")) or {}
    check(
        "config enables knowledge-base-retrieval plugin",
        "knowledge-base-retrieval" in (cfg.get("plugins", {}).get("enabled") or []),
        cfg.get("plugins", {}).get("enabled"),
    )
    check("config enables knowledge_base toolset", "knowledge_base" in (cfg.get("toolsets") or []), cfg.get("toolsets"))

    os.chdir(ROOT)
    sys.path.insert(0, str(ROOT))
    from hermes_cli.plugins import discover_plugins, get_plugin_manager, invoke_hook  # noqa: E402
    from model_tools import get_tool_definitions  # noqa: E402
    from tools.registry import registry  # noqa: E402

    discover_plugins(force=True)
    plugins = {p["key"]: p for p in get_plugin_manager().list_plugins()}
    plugin = plugins.get("knowledge-base-retrieval")
    check("plugin discovered", plugin is not None, plugins.keys())
    check("plugin enabled", plugin.get("enabled") is True, plugin)
    check("plugin has one tool", plugin.get("tools") == 1, plugin)
    check("plugin has one hook", plugin.get("hooks") == 1, plugin)
    check("plugin has one command", plugin.get("commands") == 1, plugin)
    check("plugin has no load error", plugin.get("error") in (None, ""), plugin.get("error"))

    definitions = get_tool_definitions(
        enabled_toolsets=["hermes-cli", "knowledge_base"],
        quiet_mode=True,
        skip_tool_search_assembly=True,
    )
    names = [definition["function"]["name"] for definition in definitions]
    check("knowledge_base_query appears in tool definitions", "knowledge_base_query" in names, names[-20:])
    check(
        "registry maps knowledge_base toolset to tool",
        "knowledge_base_query" in registry.get_tool_names_for_toolset("knowledge_base"),
        registry.get_tool_names_for_toolset("knowledge_base"),
    )

    raw = registry.dispatch(
        "knowledge_base_query",
        {"query": "does Knowledge Base RAG work for Hermes queries", "limit": 2, "include_pages": False},
    )
    data = json.loads(raw)
    check("knowledge_base_query dispatch succeeds", data.get("success") is True, data)
    check("knowledge_base_query returns results", bool(data.get("results")), data)
    check("knowledge_base_query FTS available", data.get("coverage", {}).get("fts_available") is True, data.get("coverage"))
    check(
        "knowledge_base_query embeddings available",
        data.get("coverage", {}).get("embedding_available") is True,
        data.get("coverage"),
    )

    hook = invoke_hook(
        "pre_llm_call",
        session_id="adhoc-skill-verify",
        task_id="adhoc-skill-verify",
        turn_id="adhoc-skill-verify",
        user_message="What did we decide about Knowledge Base as a second brain for Hermes?",
        conversation_history=[],
        is_first_turn=True,
        model="adhoc",
        platform="cli",
    )
    context = hook[0].get("context") if hook and isinstance(hook[0], dict) else ""
    check("passive hook injects context for durable query", bool(context), hook)
    check("passive hook has context tag", "<knowledge-base-context>" in context, context[:200])
    check("passive hook includes vault path", "${WORKSPACE_ROOT}/hermes-memory-wiki/vault/" in context, context[:500])

    nohook = invoke_hook(
        "pre_llm_call",
        session_id="adhoc-skill-verify",
        task_id="adhoc-skill-verify",
        turn_id="adhoc-skill-verify",
        user_message="calculate a simple number please",
        conversation_history=[],
        is_first_turn=True,
        model="adhoc",
        platform="cli",
    )
    no_context = nohook[0].get("context") if nohook and isinstance(nohook[0], dict) else ""
    check("non-durable simple query does not inject context", not no_context, nohook)

    proc = subprocess.run(
        [
            sys.executable,
            str(WIKI_ROOT / "scripts/wiki_query.py"),
            "Knowledge Base second brain Hermes integration",
            "--json",
            "--limit",
            "2",
        ],
        cwd=str(WIKI_ROOT),
        text=True,
        capture_output=True,
        timeout=30,
    )
    check("wiki_query.py exits zero", proc.returncode == 0, proc.stderr[-500:])
    cli_data = json.loads(proc.stdout)
    check("wiki_query.py returns results", bool(cli_data.get("results")), cli_data)

    print(
        json.dumps(
            {
                "summary": "ad-hoc Knowledge Base integration verification passed",
                "checks_passed": len(checks),
                "tool_top_path": data.get("results", [{}])[0].get("path"),
                "hook_context_chars": len(context),
                "cli_top_path": cli_data.get("results", [{}])[0].get("path"),
            },
            indent=2,
        )
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
