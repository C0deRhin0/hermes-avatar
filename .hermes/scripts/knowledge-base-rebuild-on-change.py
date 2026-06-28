#!/usr/bin/env python3
from __future__ import annotations

import runpy
import sys
from pathlib import Path

TARGET = Path('${WORKSPACE_ROOT}/hermes-memory-wiki/scripts/rebuild_on_change.py')
TARGET_DIR = TARGET.parent
if str(TARGET_DIR) not in sys.path:
    sys.path.insert(0, str(TARGET_DIR))
runpy.run_path(str(TARGET), run_name='__main__')
