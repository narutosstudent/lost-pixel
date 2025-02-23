<div align='center'><img width='150px' height='150px' src='https://user-images.githubusercontent.com/29632358/168112844-77e76a0d-b96f-4bc8-b753-cd39f4afd428.png'>
</div>
<div align="center">
  <h1>Lost Pixel</h1>
  <h2>Holistic visual regression testing solution </h2>  
  <a href="https://www.npmjs.com/package/lost-pixel"><img src="https://img.shields.io/npm/v/lost-pixel?style=plastic" /></a>
  <a href="https://github.com/lost-pixel/lost-pixel/blob/main/docs/contributing.md"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg" /></a>
  <a href="https://github.com/lost-pixel/lost-pixel/blob/main/LICENSE"><img src="https://img.shields.io/github/license/lost-pixel/lost-pixel" /></a>
  <br />
  <br />
  <a href="https://docs.lost-pixel.com/user-docs">Documentation</a>
  <span>&nbsp;&nbsp;•&nbsp;&nbsp;</span>
  <a href="https://docs.lost-pixel.com/user-docs/community-edition/getting-started">Quickstart</a>
  <span>&nbsp;&nbsp;•&nbsp;&nbsp;</span>
  <a href="https://github.com/lost-pixel/lost-pixel-examples">Examples</a>
  <br />
  <br />
</div>
<div align='center'>  <a href="https://www.youtube.com/watch?v=8Ws28rQymkE"><img width='400px' src='https://user-images.githubusercontent.com/29632358/187195828-92e2a8fd-0bd5-4b66-bb82-596f5688dc4d.png'> </div>
<h4 align='center'> <a href="https://www.youtube.com/watch?v=8Ws28rQymkE">Quick start video</a></div>

  <hr />

## What is Lost Pixel ❓

**Lost Pixel** is an open source visual regression testing tool. Run visual regression tests on your **Storybook** and **Ladle** stories and on your application pages.

**Lost Pixel** consists of two products:

- **lost-pixel** (*open BETA*) - the core engine driving the visual regression test runs. It could be used standalone and the main use-cases are outlined in the documentation

| What machine sees 🤖  | What human sees 👀 |
| ------------- | ------------- |
| ![ezgif-5-e71eb0773d](https://user-images.githubusercontent.com/29632358/185067771-03467437-badd-466b-ad6c-60d7183d99ae.gif) | ![ezgif-5-43091ece5d](https://user-images.githubusercontent.com/29632358/185067989-3f2d818b-c01f-4304-97f6-77295b1970d9.gif)  |
- **lost-pixel-platform** (*closed BETA*) -  the UI and CI helpers that allow you to use lost-pixel's managed version. This includes specified regression UI, collaboration with team members and easy approval/rejection process for the snapshots. Configure it just once and enjoy hassle free visual regression tests integrated into your GitHub actions pipeline. 

<hr/>
<div align="center">
 <h3> <a href="https://tally.so/r/3xXRoo">🚀 Get the platform beta invite 🚀</a></h3>
</div>
<hr/>

## Quick start ⚡

<details open>
<summary> Storybook 🖼 </summary>


Assuming you are using [basic example of Storybook]([https://github.com/tajo/ladle](https://github.com/snipcart/nextjs-storybook-example)). This setup will run visual regression tests against all the storybook stories on every push.

You can find more examples in the [examples repository](https://github.com/lost-pixel/lost-pixel-examples). You can learn more about Lost Pixel workflow and get more useful recipes in [documentation](https://docs.lost-pixel.com/user-docs).

Add `lostpixel.config.ts` at the root of the project:

```typescript
import { CustomProjectConfig } from 'lost-pixel';

export const config: CustomProjectConfig = {
  storybookShots: {
    storybookUrl: './storybook-static',
  },
  generateOnly: true,
  failOnDifference: true,
};
```

Add GitHub action `.github/workflows/lost-pixel-run.yml`

```yml
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Node
        uses: actions/setup-node@v2
        with:
          node-version: 16.x
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Build Storybook
        run: npm run build-storybook

      - name: Lost Pixel
        uses: lost-pixel/lost-pixel@2.15.0
```

</details>

<details>
<summary>Ladle example 🥄</summary>


Assuming you are using [basic example of Ladle](https://github.com/tajo/ladle). This setup will run visual regression tests against all the ladle stories on every push.

You can find more examples in the [examples repository](https://github.com/lost-pixel/lost-pixel-examples). You can learn more about Lost Pixel workflow and get more useful recipes in [documentation](https://docs.lost-pixel.com/user-docs).

Add `lostpixel.config.ts` at the root of the project:

```typescript
import { CustomProjectConfig } from "lost-pixel";

export const config: CustomProjectConfig = {
  ladleShots: {
    ladleUrl: "http://172.17.0.1:61000",
  },
  generateOnly: true,
  failOnDifference: true
};
```

Update `package.json` with following scripts:

```json
 "scripts": {
    "serve": "npx serve build -p 61000",
    "build": "ladle build"
  },
```

Add GitHub action `.github/workflows/lost-pixel-run.yml`

```yml
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Node
        uses: actions/setup-node@v2
        with:
          node-version: 16.x
          cache: "npm"

      - name: Install dependencies
        run: npm install

      - name: Build ladle
        run: npm run build

      - name: Serve ladle
        run: npm run serve &

      - name: Lost Pixel
        uses: lost-pixel/lost-pixel@v2.15.0
```

</details>

<details>
<summary>Pages example(next.js) ⚛️</summary>


Assuming you are using [basic example of Next.js](https://nextjs.org/docs). This setup will run visual regression tests against **selected pages** on every push.

You can find more examples in the [examples repository](https://github.com/lost-pixel/lost-pixel-examples). You can learn more about Lost Pixel workflow and get more useful recipes in [documentation](https://docs.lost-pixel.com/user-docs).

Add `lostpixel.config.ts` at the root of the project:

```typescript
import { CustomProjectConfig } from 'lost-pixel';

export const config: CustomProjectConfig = {
  pageShots: {
    pages: [
      { path: '/app', name: 'app' },
    ],
    pageUrl: 'http://localhost:3000',
  },
  generateOnly: true,
  failOnDifference: true,
};
```

Add GitHub action `.github/workflows/lost-pixel-run.yml`

```yml
on: [push]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v2

      - name: Setup Node
        uses: actions/setup-node@v2
        with:
          node-version: 16.x
          cache: "npm"

      - name: Install dependencies
        run: npm ci

      - name: Build Next app
        run: npm run build

      - name: Run Next app
        run: npm run start &

      - name: Lost Pixel
        uses: lost-pixel/lost-pixel@v2.15.0
```

</details>

---
## Support 👨🏼‍💻

### Ask a question about Lost Pixel

You can ask questions and initiate [discussions](https://github.com/lost-pixel/lost-pixel/discussions/) about Lost Pixel.

❓ [**Ask a question**](https://github.com/lost-pixel/lost-pixel/discussions/new)

### Create a bug report for Lost Pixel

If you see an error message or run into an issue, help us with creating a bug report!

🐛 [**Create bug report**](https://github.com/lost-pixel/lost-pixel/issues/new?assignees=&labels=kind%2Fbug&template=bug.yml)

### Submit a feature request

If Lost Pixel at the moment doesn't support some mode or does not have a feature we would appreciate your thoughts!

🆕 [**Submit feature request**](https://github.com/lost-pixel/lost-pixel/issues/new?assignees=&labels=kind%2Ffeature&template=feature.yml)

---

## Contributing 🏗️

**Lost Pixel** is open source in it's heart and welcomes any external contribution. You can refer to [CONTRIBUTING.md](https://github.com/lost-pixel/lost-pixel/blob/main/CONTRIBUTING.md) to get going with the project locally in couple of minutes.


