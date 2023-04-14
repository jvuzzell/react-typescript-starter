# React TypeScript Project Setup

This repository contains a bash script (`setup_project.sh`) that automates the process of setting up a React TypeScript project with Storybook and Jest.

## What the `setup_project.sh` script does

1. Checks if Node.js and npm are installed on your machine.
2. Creates a project directory named `my_project` and initializes npm.
3. Installs React, TypeScript, Storybook, Jest, and necessary build tools and dependencies.
4. Sets up the required configuration files for TypeScript, Webpack, and Jest.
5. Creates the project structure with an `src` directory that includes `.ts`, `.tsx`, `.stories.tsx`, and `.scss` files.

## Project Structure

After running the `setup_project.sh` script, your project should have the following structure:
```
.
├── deploy
│   └── example-config.json
├── jest.config.js
├── package-lock.json
├── package.json
├── public
│   ├── assets
│   │   └── styles
│   ├── index.html
│   ├── index.html.js
│   └── index.html.js.map
├── src
│   ├── __tests__
│   │   └── SampleComponent.test.tsx
│   ├── assets
│   ├── components
│   │   └── SampleComponent.tsx
│   ├── pages
│   │   ├── index.html
│   │   └── index.tsx
│   ├── stories
│   │   └── SampleComponent.stories.tsx
│   └── styles
│       └── components
├── tsconfig.json
└── webpack.config.js
```

## Usage

1. Save the `setup_project.sh` script to your local machine.
2. Make the script executable by running `chmod +x setup_project.sh`.
3. Execute the script with `./setup_project.sh`. 
```
# setup_project.sh automatically generates a project titled my_project

$ ./setup_project.sh

# setup_project.sh accepts one parameter for a custom project name 

$ ./setup_project.sh my_custom_project_name
```
After running the script, you can use the following commands in the `my_project` directory:

- `npm start`: Start the development server.
- `npm run build`: Build the production version.
- `npm test`: Run the Jest tests.
- `npm run storybook`: Start the Storybook server.
- `npm run build-storybook`: Build the Storybook production version.
