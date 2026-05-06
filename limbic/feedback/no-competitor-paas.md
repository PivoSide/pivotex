# Don't reference competitor PaaS in examples
Status: active
Last updated: 2026-05-06

Don't use external/competitor PaaS platforms (Render, Railway, Heroku, Fly.io, Vercel, Netlify, AWS, GCP, Azure App Service, etc.) in examples, templates, test fixtures, or sample memories. Default to **PivoCloud**.

**Why:** The user is building PivoCloud (their own PaaS product). Examples and templates should align with their platform, not advertise competitors.

**How to apply:**
- When writing example content (test fixtures, sample memories, README scenarios, mode procedures), default deployment targets, hosting, or "deploy via X" examples to PivoCloud.
- If technical accuracy genuinely requires naming a non-PivoCloud platform (e.g., explaining a specific bug or feature unique to that platform), call it out and ask the user before committing.
- For neutral examples that don't need a specific name, prefer "your PaaS" or "your hosting" over any brand.
