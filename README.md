# Solidity JWT validator

This project includes a set of contracts and a Vue-based demo that allow you to **deploy an identity contract** and then **recover it using Google Sign-In**. This is a proof-of-concept and is definitely not ready from production.

## Project setup

- Install dependencies via `npm install`
- Create a project in the [Google Developers console](https://console.developers.google.com/)
- In the Credentials section of your project, create an OAuth 2.0 for a Web Application
- Copy the client ID to your `.env` local file
- Start a local ganache instance and copy the network ID to your local `.env` file
- Update the keys in `scripts/deployKeys.js` using the [latest JWKS shared by Google](https://accounts.google.com/.well-known/openid-configuration)
- Deploy the JWKS contract running `npx truffle exec scripts/deployKeys.js --network local` and copy the deployment address to your local `.env` file
- Run locally with `npm run serve`, or set up a production build with `npm run build`

## 3rd party smart contracts

- https://github.com/adriamb/SolRsaVerify/
- https://github.com/chrisdotn/jsmnSol
- https://github.com/Arachnid/solidity-stringutils/