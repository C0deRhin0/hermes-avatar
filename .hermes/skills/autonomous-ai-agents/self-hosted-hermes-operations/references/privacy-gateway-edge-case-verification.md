# Privacy gateway edge-case verification

Use this when a privacy/policy gateway is live in front of Headroom and you need stronger proof that it is not harming normal prompts while still catching sensitive data.

## High-value probe classes

1. **Benign structured text that looks token-ish**
   - semantic versions like `v1.2.3`
   - datetimes like `2026-07-08 10:30`
   - room/build/issue numbers
   - invalid IP-like strings such as `999.999.999.999`
   - Goal: catch false positives and over-reduction.

2. **Positive PII coverage**
   - email
   - phone
   - credit card
   - SSN
   - IP address
   - JWT-like token
   - API secret/token prefixes
   - Goal: catch missed redaction classes.

3. **Payload-shape traversal**
   - `instructions`
   - `prompt`
   - root `input` strings
   - `input[*].content[*].text`
   - `messages[*].content`
   - `messages[*].content[*].text`
   - Goal: prove the extractor walks current and near-future request shapes without rewriting protocol fields like `model`, `id`, `provider`, or version metadata.

4. **Exact-output parity checks across profiles**
   - Run the same exact-output prompts through:
     - default direct-to-Headroom path
     - researcher canary via privacy-gateway
   - Use prompts that demand exact literals, exact JSON, and exact short tokens.
   - Goal: detect output degradation or instruction interference introduced by redaction.

5. **Installed-service freshness check**
   - After code changes, restart the installed privacy-gateway service before judging live canary behavior.
   - A green test suite only proves the code on disk, not the already-running systemd process.

## Good live checks

- benign probe through live HTTP path should return `x-privacy-gateway-findings=0`
- PII probe through live HTTP path should return non-zero findings
- researcher profile should still satisfy exact-output prompts after PII is stripped from the request
- Headroom `/stats` should continue showing `/v1/responses` traffic after canary probes

## Session-learned false positives worth guarding against

- short dot-delimited strings can look like JWTs unless segment length is gated
- date/time substrings can look like phone numbers unless date-ish shapes are explicitly rejected
- invalid IP-like numeric dot strings can be mistaken for JWT-like tokens if validation is too loose
