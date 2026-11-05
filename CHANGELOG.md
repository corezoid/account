# Changelog

All notable changes to this project will be documented in this file.

## Chart 0.2.48 [Account 3.32.0] - 2026-10-26
### Application Versions
- **account-frontend**: 3.32.1 (subchart 0.1.43)
- **account-auth**: 3.32.0
- **account-workspace**: 3.32.0

#### Helm changes
- **account-frontend 3.32.1** (AE-16578 / AE-16577): runtime image moved from `nginx:stable-alpine3.20` (frozen on nginx 1.26.3 / Alpine 3.20.6, EOL) to `nginx:stable-alpine3.24` (nginx 1.30.6 / Alpine 3.24.3) — fixes brotli-libs (CVE-2026-111497 / USN-8956-1), curl, libxml2 and OpenSSL findings in the 3.32.0 image (image verified: Alpine 3.24.4, brotli-libs 1.2.1-r0, curl 8.23.0, expat 2.10.0); dompurify 3.4.16 → 3.4.17 (Snyk XSS advisories, via posthog-js)
- **CSP hardening** (account-frontend, from 0.2.47): removed the attacker-registrable `https://*.ngrok-free.app` origin, added `object-src 'none'` and `base-uri 'self'`; the policy is defined once (`account.frontend.csp.value`) for the server block, SPA/API and `/avatars/` locations — server/avatars keep the narrower `*.<env>.<domain>` scope
- New optional config keys documented in `values.yaml` under `global.account.config` (passed through as-is, CGA-2550): `auth_providers.ldap.user_nick_entry`, `user_email_entry`, `idp_entity_id`, `connect_timeout_seconds`, `read_timeout_seconds`, `fallback_hosts`; `auth_providers.saml.<name>.allow_private_metadata_url`; `litellm.model`

#### New Features
- LDAP: read display name and email from the directory (`user_nick_entry` / `user_email_entry`); a first LDAP login reuses the account that owns that email or creates a new one; an entry without a usable email is refused
- LDAP: sync workspaces, roles and groups from the directory at login via the SAML maps path, enabled by `idp_entity_id`; group DNs fold into slash paths; the sync never refuses the login
- LDAP: provider exposed through the env IdP API (`config_ldap` in the listing, never the bind password; entry URL `/auth/ldap`)
- LDAP: Active Directory support — connect/read timeouts (default 10s), `fallback_hosts`, bind failures on result code 49 no longer surface as internal errors; login length limit raised from 25 to 100
- User search: search by login domain (`@sun.agency` / `sun.agency`), new partial index `logins_domain_idx` (CGA-2523)
- License search: `GET /face/api/1/licenses?all=true&search=…` with user-search matching and relevance ranking (CGA-2524)
- Users: new default `selection_stats` sort — frequently picked contacts float to the top of the picker (CGA-2519)
- LiteLLM: AI model served from account config (`litellm.model`, default `claude-sonnet-5`); new teams get the `all-proxy-models` access group (CGA-2525)

#### Enhancements
- Barrier limits: monthly fallback window anchored to the license `CreatedAt` when `NextUpdateAt` is unset (CGA-2513)
- Avatars: animated avatars encoded for delivery (480px H.264, CRF 28, `+faststart`, 400–800 KB → 60–80 KB), portrait clips cropped around the face, posters as JPEG q90 (CGA-2530)

#### Bug Fixes
- IdP role sync: system groups (All Workspace Users, Admin, Member, Guest) kept out of the SAML/LDAP group diff — fixes 400 on LDAP login and users dropped from All Workspace Users; map API answers 400 instead of 500
- LDAP: attribute names matched case-insensitively; a null attribute no longer panics the login
- Auth: every `token` cookie is tried, invalid/non-JWT tokens skipped instead of 500 (CGA-2537)
- SAML: previously stored metadata kept when a metadata fetch fails (SEC-1820)
- Workspace: `AlreadyExist` panic on concurrent first start of several pods fixed
- Deps: `aws-sdk-go-v2` modules aligned — secrets could not be loaded at startup (`not found: ComputePayloadHash`)

#### Security
- OAuth2: authorization codes bound to the client's `redirect_uri`, code exchange authenticated (`client_secret`, PKCE S256), codes single use; open redirect via `//host` paths closed
- OAuth2: full-scope cloud (Simulator) JWT minted only for codes issued to the cloud client
- LDAP: a first LDAP login is never linked to the super admin account by email; login escaped in the search filter
- SAML: SSRF protection for IdP metadata URLs (CWE-918) — https only, private/loopback/metadata IPs refused; per-IdP `allow_private_metadata_url` for on-prem IdPs (SEC-1820)
- Deps: Go 1.24 → 1.26.9, govulncheck findings patched (SEC-1908)

#### Upgrade Notes
- Migration `000089_logins_domain_index` runs on startup
- LiteLLM: teams provisioned before this release keep `models: ["default"]` — run `scripts/litellm_teams_all_proxy_models.sh` (`--apply` to write) after deploying and before dropping the `default` group from the proxy (CGA-2526)
- LDAP: setting `idp_entity_id` makes every login reconcile roles against the directory and removes roles no map grants — set it only once the maps are in place

## Chart 0.2.46 [Account 3.31.0] - 2026-09-11
### Helm changes
- Avatar normalisation: the 16:9 band cut out of taller clips is placed around the face (centre at
  `FACE_Y` = 36 % of the height; a centre band showed the chin on Veo's 9:16 output), and the CRF is
  raised in steps of 3 up to `MAX_CRF` (34) until the clip is under `TARGET_BYTES` (100 KB); clips that
  stay above the target at `MAX_CRF` are marked in `<volume>/.orig/.state/` and not retried nightly.

## Chart 0.2.45 [Account 3.31.0] - 2026-09-11
### Helm changes
- Avatar normalisation: clips taller than 16:9 (Veo's 480x854 portrait output that the generator failed
  to crop — 356 of the 1032 prod files, 150–1400 KB even at 480 px wide) are centre-cropped to
  `MAX_HEIGHT` (270); the meeting tile shows exactly that band (`object-fit: cover`). A rewrite starts
  from the backed-up original when there is one, so re-running never stacks generation loss.

## Chart 0.2.44 [Account 3.31.0] - 2026-09-11
### Application Versions
- **account-frontend**: 3.31.0 (subchart 0.1.39)
- **account-auth**: 3.31.0
- **account-workspace**: 3.31.0

#### Helm changes
- **Avatar normalisation CronJob** (CGA-2529 / CGA-2530): optional `global.account.frontend.avatars.normalize`
  (disabled by default) runs `charts/account-frontend/files/avatars-normalize.sh` in the
  account-workspace image on the shared avatars volume — re-encodes `animation/<id>.mp4` to
  480px H.264 constrained baseline, CRF 28, no audio, `+faststart` (400–800 KB → 60–80 KB) and
  converts PNG-bytes posters `animation/<id>.jpg` to real JPEG (~900 KB → ~40–60 KB). Idempotent,
  originals kept once under `<volume>/.orig/`, atomic replace, `dry_run`/`limit` knobs.
- `/avatars/` locations that answer a miss with the placeholder / 404 no longer log the expected
  `open() failed` at error level (`log_not_found off`).

## Chart 0.2.43 [Account 3.31.0] - 2026-09-11
### Application Versions
- **account-frontend**: 3.31.0 (subchart 0.1.38)
- **account-auth**: 3.31.0
- **account-workspace**: 3.31.0

#### Helm changes (account-frontend nginx, `/avatars/`)
- **Cache-Control for avatars** (CGA-2527): URLs with a `?v=<N>` cache-buster get
  `public, max-age=31536000, immutable`; URLs without `?v=` get `public, max-age=86400`;
  placeholders, fallbacks and 404s get `public, max-age=120`. Values under
  `global.account.frontend.avatars.cache.*`. Previously only the `<WxH>` resize locations sent
  `expires 1d`; everything else was un-cacheable.
- **404 instead of a placeholder for unsupported avatar paths** (CGA-2528): anything under
  `/avatars/` that is not a supported URL shape (e.g. `/avatars/animation/<id>.webm`,
  `/avatars/workspaces/<ws>/52x52/animation/<id>.jpg`) now returns 404 (was 302 → 390-byte
  placeholder or 415). A user who has no avatar still gets the placeholder, now as a direct 200
  (`/static/avatar.jpg`, `/static/anonymous.jpg`, `/static/anonymous.mp4`) instead of a 302.
  `/avatars/animation/<id>.mp4` for a user who has a photo but no animation returns 404 instead
  of the JPEG body with a video URL.
- **Resized poster frames** (CGA-2529): new `/avatars/animation/<WxH>/<id>.jpg?v=N`, cropped by
  an internal loopback resize server and cached on the pod's local disk (`proxy_cache`, key includes
  `?v=`). `X-Cache-Status` and `X-Avatar-Source` response headers expose cache state / fallbacks.
  Values under `global.account.frontend.avatars.poster.*` (`enabled: true` by default).
- Tightened the `/avatars/` regex locations (`<WxH>` must be digits, one path segment per part);
  the old `(.+)x(.+)/(.+)` patterns mis-parsed nested paths and produced 415s.
- Repeated per-location security/CORS/CSP headers moved into the named template
  `account.frontend.avatars.headers` (rendered output identical).
- JSON access log: `upstream_response_time` is now quoted — for static responses nginx renders it
  empty, which produced invalid JSON (`"upstream_response_time": ,`) for every `/avatars/` line.
- `develop` re-synced with `main` (the `/avatars/animation/<id>.mp4` location from 0.2.38 had only
  landed on `main`).

## Chart 0.2.42 [Account 3.31.0] - 2026-08-10
### Application Versions
- **account-frontend**: 3.31.0
- **account-auth**: 3.31.0
- **account-workspace**: 3.31.0

#### New Features
- Barrier limits: contract-driven daily/weekly/monthly caps on the Face API, with per-window usage and UTC-aligned resets (CGA-2513)
- Barrier limits: default limits are synthesized from the license state-change quota when no contract is applied (CGA-2513)

#### Enhancements
- Barrier limits: dropped limits_version tracking — upsert is now an unconditional last-writer-wins overwrite (CGA-2513)
- Config files untracked from the repository; live credentials replaced with environment-variable placeholders (SEC-1422)

#### Bug Fixes
- Barrier limits: default monthly quota now scales by the license M size instead of using raw units (CGA-2513)

## Chart 0.2.41 [Account 3.29.6] - 2026-07-16
### Application Versions
- **account-frontend**: 3.28.0
- **account-auth**: 3.29.6
- **account-workspace**: 3.29.6

#### Bug Fixes
- Hotfix for account-auth and account-workspace

## Chart 0.2.39 [Account 3.29.5] - 2026-07-07
### Application Versions
- **account-frontend**: 3.28.0
- **account-auth**: 3.29.5
- **account-workspace**: 3.29.5

#### New Features
- Personalized user search ranking based on selection history
- Improved transliteration support for user search (Cyrillic/Latin spelling variants)
- Task log archival: optional long-term retention of task history in object storage
- OAuth2 Dynamic Client Registration (DCR) and OIDC discovery
- AI token management API (LiteLLM integration)
- Stripe invoices displayed on the Payments page
- Workspace ownership transfer via checkbox
- User timezone settings
- Suggest selection from a list of authorized profiles

#### Enhancements
- Improved search ranking accuracy and reduced false matches from transliteration
- TLS support for Redis/ElastiCache in auth and workspace services
- Enforced group owner assignment across all environments

#### Bug Fixes
- Fixed incorrect search results caused by transliteration artifacts
- Fixed OAuth2 token response format and JWT issuance for cloud clients
- Fixed license retention permissions and settings issues
- Fixed incorrect user search results by email in Simulator
- Fixed Keycloak login display (username instead of email)
- Fixed user permission transfer issue in the instance users list
- Fixed AI avatar generation failure with text-containing photos
- Fixed missing search indexing for newly registered users

## Chart 0.2.37 [Account 3.26.4] - 2026-05-22
### Application Versions
- **account-frontend**: 3.26.2
- **account-auth**: 3.26.4
- **account-workspace**: 3.26.4

#### New Features
- API for attaching files to payments

#### Enhancements
- SSO improvements and login notifications to Corezoid
- Sorting users by domain

#### Bug Fixes
- Included fixes as listed in the release notes

## Chart 0.2.36 [Account 3.26.0] - 2026-03-18
### Application Versions
- **account-frontend**: 3.26.0
- **account-auth**: 3.26.0
- **account-workspace**: 3.26.0

#### New Features
- Add timezone support across auth and user APIs
- Add timezone and user_timezone columns to users table
- Return timezone offset in /oauth2/userinfo response
- Return timezone offset in GetShort response
- Update timezone on UserInfo from X-User-Timezone header

#### Enhancements
- Return timezone offset in minutes instead of timezone name
- Extract timezone offset calculation into separate function
- Bump user cache key version to u.2

#### Bug Fixes
- Accept nullable timezone in UpdateUserTimezone
- Handle deprecated Europe/Kiev timezone on server
- Log warning on invalid timezone in timezoneOffset

## Chart 0.2.35 [Account 3.25.1] - 2026-02-18
### Application Versions
- **account-frontend**: 3.25.0
- **account-auth**: 3.25.1
- **account-workspace**: 3.25.1

#### New Features
- Add total_extra parameter to the payload for tracking total purchased extra state changes (includes new purchased + remaining)
- Implement auto-charge functionality for extra state changes
- New video avatars

#### Enhancements
- Add support for new video avatar format

#### Bug Fixes
- Fix production issues with license and user services

## Chart 0.2.34 [Account 3.22.0] - 2025-11-17
### Application Versions
- **account-frontend**: 3.21.2
- **account-auth**: 3.22.0
- **account-workspace**: 3.22.0

#### New Features
- API for attaching files to payments

#### Enhancements
- SSO improvements, notifications to Corezoid for user login
- Sorting users by domain
- Bugfix

## Chart 0.2.33 [Account 3.21.0] - 2025-10-21
### Application Versions
- **account-frontend**: 3.21.0
- **account-auth**: 3.21.5
- **account-workspace**: 3.21.5

#### New Features
- Replicate user rights feature
- Implement User Avatar APIs for Workspaces
- Add webhook event types configuration for API Keys
- Extend User Model with animation field and update related APIs
- Add field `company_domain` to Workspace settings

#### Enhancements
- Refactor License and License Attributes Logic (State Changes)
- Restrict license visibility and editing to shared user's licenses
- Adjust behavior of user dropdown list in dialogs (e.g., when removing a user from a workspace)
- Add fallback image to the build

## Chart 0.2.32 [Account 3.20.0] - 2025-10-07
### Added
- Added support for custom annotations in account-frontend service through configurable template values

### Changed
- Updated account-frontend subchart version to 0.1.30

## Chart 0.2.31 [Account 3.20.0] - 2025-09-04
### Added
- EFS (Elastic File System) PersistentVolume and PersistentVolumeClaim support
- Conditional EFS volume mounting in account-workspace, account-auth, and account-frontend deployments
- EFS storageSize parameter in values.yaml configuration
- Shared storage capability between application pods when global.efs.enabled=true

### Changed
- Updated account-workspace subchart version to 0.1.35
- Updated account-auth subchart version to 0.1.35  
- Updated account-frontend subchart version to 0.1.29

## Chart 0.2.30 [Account 3.20.0] - 2025-08-20
### Helm changes
- **account-frontend**: Added "path" field to nginx JSON log format
  - Added `"path": "$uri"` field to the existing JSON log structure
  - Incremented account-frontend subchart version from 0.1.26 to 0.1.27
- **account-frontend**: Updated nginx redirect configuration to use add_header Location for relative path redirects
  - Changed `@redirect` location block from `return 302 /avatars/54x54/0.jpg;` to `add_header Location /avatars/54x54/0.jpg; return 302;`
  - Incremented account-frontend subchart version from 0.1.27 to 0.1.28
  - Updated root chart dependency reference to account-frontend 0.1.28

## Chart 0.2.29 [Account 3.20.0] - 2025-08-20
### Helm changes
- **account-frontend**: Updated nginx log format from tab-separated to JSON format
  - Converted `up_log` format to JSON structure with `escape=json` parameter
  - Preserved all existing log fields: server_addr, server_port, http_x_forwarded_for, time_iso8601, upstream_addr, request, status, body_bytes_sent, request_time, upstream_response_time, http_referer, http_user_agent, host
  - Incremented account-frontend subchart version from 0.1.25 to 0.1.26

## Chart 0.2.28 [Account 3.20.0] - 2025-07-18
### Helm changes
- Added support for custom annotations in application deployments through configurable template values.

## Chart 0.2.27 [Account 3.20.0] - 2025-07-07
### Helm changes
### Application Versions
- **account-frontend**: 3.20.0
- **account-auth**: 3.20.0
- **account-workspace**: 3.20.0

### New Features
1. Always return sim_url per workspace in GET client/users/me
2. API user is now created as a regular user with a workspace on /client/api/1/users/me
3. Add option to connect User's AI in workspace settings
4. Add a File TTL Settings option to workspace configuration
5. Implement API endpoint GET /providers for listing available model providers and models
6. Add User Token Management to Main Settings section
7. Backend support for User Token Management

### Enhancements
1. Periodically generate 2 free licenses per user; one remains in pending status
2. Retrieve parameters from the Secret Provider
3. Develop smoke tests and write scripts using Magnitude

### Bug Fixes
1. Super admin can't update root license via account or Corezoid if license expired for more than one month
2. White screen without error message when login/password is incorrect and reCAPTCHA is disabled
3. Logout endpoint /api/1/admin/users/logout not working correctly

## Chart 0.2.26 [SingleSpace] - 2025-06-13

### Changed
- account-auth
- account-workspace

### New Features
- Added conditional environment variables for external secret provider configuration
- Added EXTERNAL_SECRET_PROVIDER environment variable from global.account.secrets.external_secret_provider
- Added AWS_SECRET_REGION environment variable from global.account.secrets.aws.aws_secret_region
- Added AWS_SECRET_NAMES environment variable from global.account.secrets.aws.aws_secret_names
- Added proper validation for secrets block existence using hasKey function
- Created _container_envs_secrets.yaml template helper following existing patterns

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## Chart 0.2.26 [Account 3.19.1] - 2025-05-19
### Helm changes
- Applications versions:
  - auth - 3.19.1
  - workspace - 3.19.1
  - frontend - 3.19.1
  - ingress - 0.1.2
  - valkey - 0.1.9
- Added custom labels support to account-frontend subchart:
  - Implemented ability to define custom labels in values.yaml that will be applied to all resources
  - Added proper documentation and examples for the new feature
- Added support for custom labels in workspace subchart:
  - Implemented ability to define custom labels in values.yaml
  - Labels are applied to all Kubernetes resources generated by the workspace subchart
  - Added commented example in values.yaml showing proper syntax
- Added support for custom labels in account-auth subchart
- Added support for custom labels in account-valkey subchart

## Chart 0.2.25 [Account 3.19.1] - 2025-04-25
### Helm changes
- Applications versions:
  - auth - 3.19.1
  - workspace - 3.19.1
  - frontend - 3.19.1
  - ingress - 0.1.2
  - valkey - 0.1.9
- Added image signature verification support for all components:
  - Enhanced `AccountInitVerifyImageSignature` template with improved error handling and architecture detection
  - Added configuration options for enabling signature verification in all subcharts
  - Added support for private registry authentication during verification
  - Added proper volume mounting for cosign public keys

## Chart 0.2.24 [Account 3.19.1] - 2025-04-24
### Helm changes
- Applications versions:
  - auth - 3.19.1
  - workspace - 3.19.1
  - frontend - 3.19.1
  - ingress - 0.1.2
  - valkey - 0.1.9
- Enhanced affinity configuration for all components:
  - Added component-specific affinity support for auth, frontend, and workspace
  - Improved affinity configuration hierarchy (component-specific takes precedence over global)
  - Fixed podAntiAffinity configuration to ensure it's always applied regardless of custom affinity settings
  - Added proper anti-affinity rules for frontend component

## Chart 0.2.23 [Account 3.19.1] - 2025-04-22.
### Helm changes
- Applications versions:
  - auth - 3.19.1
  - workspace - 3.19.1
  - frontend - 3.19.1
  - ingress - 0.1.2
  - valkey - 0.1.8
- Refactored init containers in `account-auth` and `account-workspace` subcharts to use reusable templates
- Added initWait container for checking if database exists.
- Added liveness and readiness probes to account-frontend deployment
- Update local `valkey` up to `8.1` version.
- Improved `account-auth` subchart:
  - Enhanced Chart.yaml with better description, keywords, and maintainer information
  - Updated values.yaml with improved documentation and default resource configurations
  - Upgraded HPA to autoscaling/v2 API with support for memory metrics and scaling policies
  - Added pod anti-affinity rules for better distribution across nodes
  - Improved service configuration with support for different service types and annotations
  - Enhanced monitoring configuration with better metric collection options
  - Added lifecycle hooks for graceful termination
  - Improved RBAC documentation and added standard Kubernetes labels
- Improved `account-workspace` subchart:
  - Enhanced Chart.yaml with better description, keywords, and maintainer information
  - Updated values.yaml with improved documentation and default resource configurations
  - Upgraded HPA to autoscaling/v2 API with support for memory metrics and scaling policies
  - Added pod anti-affinity rules for better distribution across nodes
  - Improved service configuration with support for different service types and annotations
  - Fixed monitoring template with correct labels and enhanced configuration
  - Added lifecycle hooks for graceful termination
  - Improved RBAC with better labels and documentation


## Chart 0.2.22 [Account 3.19.0] - 2025-03-26.
### Helm changes
- Applications versions:
  - auth - 3.19.0
  - workspace - 3.19.0
  - frontend - 3.19.0
  - ingress - 0.1.2
  - valkey - 0.1.8
- Added condition to check if `auth_providers` exists before accessing `auth_providers.saml`
- Added condition for creating `ServiceAccount`, Role, and RoleBinding based on `serviceAccount.create` value
- Added condition to check if `imagePullSecrets` exists before accessing `imagePullSecrets.name`

### New Features
 - Enable the ability to forcibly turn on `2FA` in the environment (Backend & Frontend)
 - Create an API to retrieve the `2FA` status of a user
 - Add the option to specify the authentication provider (SSO) as hidden

### Enhancements
 - Upgrade React library version and related dependencies
 - Improve signup password validation rules view
 - Improve display error on UI when confirming registration under another account
 - Optimize requests for `/client/api/1/licenses/workspaces/{id}` and `/client/api/1/licenses/users/{id}`
 - The order of permissions in the role matrix and the API key list has changed

### Bug Fixes
 - Resolve user session timeout issue
 - Fix logout issue
 - Fix dashboard view
 - Solve lint issues

### Security & API Changes
 - Preserve settings field in API requests when updating workspaces
 - Support `workspace_id` parameter in API for debiting transactions
 - Analyze the need for "public" API for frontend and remove unnecessary usage


## Chart 0.2.21 [Account 3.18.0] - 2025-02-11.
### Helm changes
- Applications versions:
  - auth - 3.18.1
  - workspace - 3.18.1
  - frontend - 3.18.0
  - ingress - 0.1.2
  - valkey - 0.1.8
- Fixed bugs.


## Chart 0.2.20 [Account 3.18.0] - 2025-01-30.
### Helm changes
- Applications versions:
  - auth - 3.18.0
  - workspace - 3.18.0
  - frontend - 3.18.0
  - ingress - 0.1.2
  - valkey - 0.1.8
- Add internal `valkey` set in values file.
- Add flag for disable `auth` application.
- Add resolve in initWat containers for database and redis.
- Added an API to expire user passwords.
- Fixed bugs related to user blocking.


## Chart 0.2.19 [Account 3.17.0] - 2025-01-21.
### Helm changes
- Applications versions:
  - auth - 3.17.3
  - workspace - 3.17.3
  - frontend - 3.17.0
  - ingress - 0.1.2
- fixed goroutine leaks
- fixed caching logic of api /client/users/short


## Chart 0.2.18 [Account 3.17.0] - 2025-01-20.
### Helm changes
- Applications versions:
  - auth - 3.17.1
  - workspace - 3.17.1
  - frontend - 3.17.0
  - ingress - 0.1.2
- Added support for oneApp mode.
- Active-active configuration support.
- state changes calculation fixed
- Resolved various bugs and implemented stability improvements


## Chart 0.2.17 [SingleSpace 3.16.0] - 2024-12-19.
### Helm changes
- Applications versions:
  - auth - 3.16.2
  - workspace - 3.16.2
  - frontend - 3.16.0
  - ingress - 0.1.2
- SSO authorization: added new type of mappers - const_links
- Added client API for updating users online status
- Public API: added new endpoint for updating list users in the group
- Synchronization of user sessions between clients
- Bug fixes ldap auth


## Chart 0.2.16 [SingleSpace 3.15.0] - 2024-11-29.
### Helm changes
- Applications versions:
  - auth - 3.15.0
  - workspace - 3.15.0
  - frontend - 3.15.0
  - ingress - 0.1.2
- Bug fixes for the groups APIs
- SSO authorization added

## Chart 0.2.15 [SingleSpace 3.14.0] - 2024-11-15.
### Helm changes
- Applications versions:
  - auth - 3.14.0
  - workspace - 3.14.0
  - frontend - 3.14.0
  - ingress - 0.1.2


## Chart 0.2.14 [SingleSpace 3.13.0] - 2024-10-18.
### Helm changes
- Applications versions:
  - auth - 3.13.2
  - workspace - 3.13.2
  - frontend - 3.13.0
  - ingress - 0.1.2
- Bugfix
- Metrics are enabled by default

## Chart 0.2.13 [SingleSpace 3.13.0] - 2024-10-10.
### Helm changes
- Applications versions:
  - auth - 3.13.1
  - workspace - 3.13.1
  - frontend - 3.13.0
  - ingress - 0.1.2
- Add `liveness` and `readiness` for `auth` and `workspace` applications


## Chart 0.2.12 [SingleSpace 3.13.0] - 2024-10-08.
### Helm changes
- Applications versions:
  - auth - 3.13.1
  - workspace - 3.13.1
  - frontend - 3.13.0
  - ingress - 0.1.2
- Added `cookie_same_site` attribute to the config (optional)
- New `imageRegistry` url

### Improvements / New Features
#### 1. client APIs added: CRUD operations for groups and API keys
#### 2. graceful shutdown added
#### 3. bug fixes


## Chart 0.2.11 [SingleSpace 3.12.5] - 2024-09-30.
### Helm changes
- Applications versions:
  - auth - 3.12.5
  - workspace - 3.12.5
  - frontend - 3.12.4
  - ingress - 0.1.2
- Add parameter `content_security_policy` in values file.
- The minimum number of characters in the password has been increased


## Chart 0.2.10 [SingleSpace 3.10.0] - 2024-07-31.
### Helm changes
- Applications versions:
    - auth - 3.10.6
    - workspace - 3.10.6
    - frontend - 3.10.0
    - ingress - 0.1.2
- Add parameter `portMetrics` in values file, using for define port for metrics
- Add monitoring for `auth`
- Update monitoring manifest for `workspace`

## Chart 0.2.9 [SingleSpace 3.10.0] - 2024-07-29.
### Helm changes
- New applications versions:
    - auth - 3.10.6
    - workspace - 3.10.6
    - frontend - 3.10.0
    - ingress - 0.1.2
- Remove hardcode registry domain from sub-charts. Switch to `{{ .Values.global.imageRegistry }}`

## Chart 0.2.8 [SingleSpace 3.10.0] - 2024-07-08
### Helm changes
- New applications versions:
    - auth - 3.10.0
    - workspace - 3.10.0
    - frontend - 3.10.0
    - ingress - 0.1.2

### Improvements / New Features

#### 1. The Webhooks page has been added to Settings where ** you can create, edit, manage, and delete webhooks.

    Note: You can manage webhooks if you have the Owner, Admin, Member or custom role and the Manage all webhooks permission.

#### 2. When you are transferring your workspace ownership to other user:
- You can cancel the ownership transfer before the selected user accepts it.
- The selected user can accept or decline the ownership transfer.
- The ownership transfer is canceled if the selected user is blocked or deleted.


## Chart 0.2.7 [SingleSpace 3.9.0] - 2024-06-26
### Helm changes
- Applications versions:
    - auth - 3.9.0
    - workspace - 3.9.0
    - frontend - 3.9.0
    - ingress - 0.1.2
- Changes for imagePullSecrets creation
```
      {{- if .Values.global.imagePullSecrets }}
      imagePullSecrets:
      {{- range $pullSecret := .Values.global.imagePullSecrets }}
        - name: {{ $pullSecret }}
      {{- end }}
      {{- end }}
```
- Remove hardcode `resources` from `values.yaml` file

## Chart 0.2.5 [SingleSpace 3.9.0] - 2024-06-12
### Helm changes
- New applications versions:
    - auth - 3.9.0
    - workspace - 3.9.0
    - frontend - 3.9.0
    - ingress - 0.1.2

### Improvements / New Features

#### 1. In the workspace dropdown list, you can see the list of workspaces you have access to and your roles in each workspace.

Note:

        If you have multiple roles in one workspace, they appear in a row below the workspace name.
        If the workspace is blocked, it has a red dot next to its name.

#### 2. On the Details tab of your paid online Cloud license, you can add another card details by clicking Change next to Payment method.

#### 3. The users with the Super admin role, can view:
- All the licenses and their details of all the users of the environment, filter them by Statuses (Active, Blocked, Cancelled, and Pending) and Ownership (Only my licenses), and edit license attribute details (for example, change RPS or cancel the license) of the other user paid license.
- All the payments and their details of all the users of the environment and filter them by Statuses (Paid, Failed, Pending).

#### 4. The users blocked due to the end of the license trial period can unblock themselves by passing the authorization process and logging in to the application again: Now, the free license don't have the expiration date.


## Chart 0.2.4 [SingleSpace 3.8.0] - 2024-05-28
### Helm changes
- New applications versions:
    - auth - 3.8.0
    - workspace - 3.8.0
    - frontend - 3.8.0
    - ingress - 0.1.2
- Refactor resources in helm chart, resources moved to values.yaml file.
- Updated code-style

### Improvements / New Features

#### 1. In the Licenses & Billing space, the super admin can:
 - View the Workspace page and all the workspaces with their details: workspace name, owner name, license type and ID, license owner name, number of workspace users, workspace status, and creation date.
 - Upload the In-House license on their instance on the Upload license page of the Null Workspace.

       Note: When uploading a license, you can compare the previous license details and the actual one's in the dialog that appears.

#### 2. The workspace owner can configure the rules to invite users to their workspace:
 - To invite or not to invite users in general
 - To allow all user domains
 - To specify allowed user domains
 - To specify prohibited user domains


## Chart 0.2.3 [SingleSpace 3.7.0] - 2024-05-07
### Helm changes
- New applications versions:
    - auth - 3.7.0
    - workspace - 3.7.0
    - frontend - 3.7.0
    - ingress - 0.1.2

### Improvements / New Features
- User migrations
- Bug fix sql migration
- When you turn on the Enable Two-factor authentication toggle on the Profile page, the QR codes to upload the authentication application for Android and iOS appear on the step 2.
- When you buy a license on the Simulator.Company website, you can buy extra state changes by clicking Buy more on the Details tab of the license page.

## Chart 0.2.2 [SingleSpace 3.6.0] - 2024-04-25
### Helm changes
- New applications versions:
    - auth - 3.6.0
    - workspace - 3.6.0
    - frontend - 3.6.0
    - ingress - 0.1.2

### Improvements / New Features

#### 1. On the Licenses & Billing page:
- On the Licenses tab, you can view the type of license: Cloud, Desktop, or In-House.
- On the Payments tab, you can download the invoice of the license paid according to the agreement with the invoice.
- On the Details tab of a license, you can view state changes statistics: income amount, regular renewal amount, bonuses, used amount, and current balance.

#### 2. On the Roles page, you can edit the Member role permissions by selecting or clearing the needed checkboxes.


## Chart 0.2.1 [SingleSpace 3.5.0] - 2024-04-09
### Helm changes
- New applications versions:
    - auth - 3.5.0
    - workspace - 3.5.0
    - frontend - 3.5.1
    - ingress - 0.1.2
- Refactor sub charts

### Improvements / New Features

The following features have been added and improved:

#### 1. The password history has been added: you have to change your password after a specified period of time, and you cannot reuse any of your last 10 passwords.
        Note: This refers to those users who have registered by entering a username and password and not entered by using Google account.

#### 2. You can select a colour instead of adding an image:

          a. On the Profile page for your avatar

          b. On the Keys page, when creating an API key

#### 3. On the Users tab of the Groups page, you can see the Roles and Last login columns.


## Chart 0.2.0 [SingleSpace 3.4.0] - 2024-03-20
### Helm changes
- New applications versions:
    - auth - 3.4.0
    - workspace - 3.4.0
    - frontend - 3.4.0
    - ingress - 0.1.0
- Refactor sub charts
- Refactor values.yaml (we have added a separate config block for the auth and workspace applications)
- **Attention, Release of the new authorization module!
  This module operates independently of the Erlang application. Prior to installation, we recommend consulting for guidance.**

### Improvements / New Features

The following features have been added and improved:

#### 1. You can enter user names in Cyrillic in the Sign in form.
#### 2. The redesign of the Profile page has been implemented.
#### 3. You can view all your Workspaces even if you have them more than 100 by using scroll.
#### 4. The counters have been fixed when filtering users.


## Chart 0.1.18 [SingleSpace 3.2.0] - 2024-01-09
### Helm changes
- New applications versions:
    - auth - 3.2.4
    - workspace - 3.2.4
    - ingress - 0.1.0
- Added to app names `account-`
- Added new application `account-frontend` - currently in development, should be disabled
- Refactor sub charts

### Improvements / New Features

On the Roles tab, the Roles table has been improved:
- Virtualisation has been added.
- The limit of pagination parameters has been increased to 999.


## Chart 0.1.17 [SingleSpace 3.1.1] - 2023-12-06
### Helm changes
- New applications versions:
   - auth - 3.1.1
   - workspace - 3.1.1
   - ingress - 0.1.0
- Rename application `singlespace` to `workspace`
- Add new application `auth` for authorization
- Refactor sub charts

### Improvements / New Features

#### 3.1.0:
- Created the public API of the following groups: Workspaces, Groups, Invites, Users. For more information, go to Swager.
- You can transfer your Workspace ownership to another user. When you leave a Workspace, transfer your Workspace ownership to another user, have been removed from a Workspace, or remove a user form a Workspace, you have to transfer your/removed user’s objects ownership to another user. For more information, go to Settings.
- Created MVP of the new authorization module.
- When you invite a user to your Workspace, your invitation has no expiration date, and the invited user can confirm your invitation after any period of time.

#### 3.0:
- On the Roles tab, you can see the roles as a list with the number of permissions and users for each role by clicking the corresponding icon in the upper-right corner of the page.
- Implemented a new module with licenses that allows you to buy a license, make payments, track state changes, and so on.
- Your company in Corezoid will appear as your company in Simulator as well. But when deleting the last company, you will have a new one anyway as you cannot have no company on the platform.



## Chart 0.0.17 [SingleSpace 2.14.2] - 2023-08-19
### Helm changes
- New applications versions:
    singlespace - 2.15.1
    ingress - 0.1.0

- Add `Role`, `RoleBinding` and `ServiceAccount` for singlespace appliction
- Add new block for `serviceAccount`

```
      # Specifies whether a service account should be created
      serviceAccount:
        create: false
        # You can provide your serviceAccount name to use, also set create to false
        # name: ""
        annotations: {}
        # annotations:
        # ## Enable if EKS IAM for SA is used
        #   eks.amazonaws.com/role-arn: arn:aws:iam::123456789012:role/my-role
```

## Chart 0.0.16 [SingleSpace 2.14.0] - 2023-07-25
### Helm changes
- New applications versions:
    singlespace - 2.14.0


## Chart 0.0.15 [SingleSpace 2.13.0] - 2023-06-07
### Helm changes
- New applications versions:
    singlespace - 2.13.0


## Chart 0.0.14 [SingleSpace 2.11.0] - 2023-05-26
### Helm changes
- New applications versions:
    singlespace - 2.11.0


## Chart 0.0.13 [SingleSpace 2.10.0] - 2023-05-25
### Helm changes
- New applications versions:
    singlespace - 2.10.0


## Chart 0.0.12 [SingleSpace 2.9.0] - 2023-05-11
### Helm changes
- New applications versions:
    singlespace - 2.9.0
- Add new parameter `secret`. Must be same as `admin_bearer_token_secret` in `single_account.config` file


## Chart 0.0.11 [SingleSpace 2.6.1] - 2023-04-19
### Helm changes
- New applications versions:
    singlespace - 2.6.1


## Chart 0.0.10 [SingleSpace 2.6.1] - 2023-04-06
### Helm changes

- Аdded the ability to work with self-signed certificates

#### Improvements

- Draft implementation of webhooks.
- New config parameter: tls.insecure_skip_verify - skips certificate validation in http requests.

#### Feature

- Initiate changelog file


## Chart 0.0.9 [SingleSpace 2.5.0] - 2023-04-06
### Helm changes

- New chart release
- New application version
    singlespace - 2.5.0


## Chart 0.0.8 [SingleSpace 2.4.0] - 2023-03-29
### Helm changes

- New chart release
- New application version


## Chart 0.0.1 [SingleSpace 2.0.0] - 2023-01-13
### Helm changes

- Init chart
