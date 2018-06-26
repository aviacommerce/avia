# Snitch API

This phoenix API server exposes Snitch via a Spree like interface, and
integrates well with most Spree frontends such as [Angularspree][angularspree].

To start your Phoenix server:

- Install dependencies with `mix deps.get`
- Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4100`](http://localhost:4100) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Snitch frontend

Though you can use any Spree frontend, we highly recommend the `develop` branch
on [Angularspree][angularspree].
All you have to do is:

- clone [Angularspree][angularspree], just the `develop` branch will do:
  ```sh
  git clone https://github.com/aviabird/angularspree.git -b develop
  ```
- Angularspree uses `yarn`, so [install that][yarn-install].
- Once inside the `angularspree` directory, run:
  ```sh
  npm install -g @angular/cli
  ```
- The frontend needs to be configured manually, just drop this snippet in `src/config/custom/custom.ts`

  ```typescript
  // src/config/custom/custom.ts

  import { APP_DATA } from './app-data';

  export const CUSTOM_CONFIG = {
    // Add Your custom configs here
    prodApiEndpoint: 'http://localhost:4100/',
    appName: 'Custom App Name',
    fevicon: 'http://via.placeholder.com/350x150',
    header: {
      brand: {
        logo: "/assets/default/logo.png",
        name: "Angularspree",
        height: "40",
        width: "112"
      },
      searchPlaceholder: 'Find the best product for me ...',
      showGithubRibon: false,
    },
    ...APP_DATA
  };
  ```

- Run the frontend!
  ```sh
  yarn install
  yarn start:dev-ng-spree
  ```

[yarn-install]: https://yarnpkg.com/lang/en/docs/install/

## Learn more

- Official website: http://www.phoenixframework.org/
- Guides: http://phoenixframework.org/docs/overview
- Docs: https://hexdocs.pm/phoenix
- Mailing list: http://groups.google.com/group/phoenix-talk
- Source: https://github.com/phoenixframework/phoenix

[angularspree]: https://github.com/aviabird/angularspree/tree/develop
