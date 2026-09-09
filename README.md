# Enchiridion

A Jekyll site for the Enchiridion of Epictetus, an ancient handbook to the philosophy of Stoicism.

The site is a progressive web app (PWA), hosted at <https://coedice.github.io/enchiridion/>, and can be installed on your device to read offline.

## Install as an app

Open <https://coedice.github.io/enchiridion/> in your browser, then:

**Chrome / Edge (desktop)**
Click the install icon in the address bar, or use the browser menu → **Install page as app** (Edge: **Apps → Install this site as an app**).

**Android (Chrome)**
Browser menu → **Install app** (or **Add to Home screen**).

**iPhone / iPad (Safari)**
Share button → **Add to Home Screen**.

Once installed, Enchiridion opens full-screen from an icon on your home screen, dock, or start menu, and works offline via a service worker that caches the book.

## Local development

Run `make build` from the repo root to serve the site locally at <http://localhost:8080>. The build runs in Docker (`jekyll/jekyll`).
