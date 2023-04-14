#!/bin/bash

# This script creates the project structure and installs all the necessary dependencies, including React, TypeScript, Storybook, and Jest. It also sets up the configuration files for TypeScript, Webpack, and Jest. The `src` directory is created and only contains the `index.tsx` file.

# To run the project, use the following commands in the project directory:
# - `npm start`: Start the development server.
# - `npm run build`: Build the production version.
# - `npm test`: Run the Jest tests.
# - `npm run storybook`: Start the Storybook server.
# - `npm run build-storybook`: Build the Storybook production version.

# Check if Node.js and npm are installed
if ! command -v node &>/dev/null; then
  echo "Node.js is not installed. Please install Node.js and try again."
  exit 1
fi

if ! command -v npm &>/dev/null; then
  echo "npm is not installed. Please install npm and try again."
  exit 1
fi
  
# Check project name
if [ "$1" != "" ];then 
  project_name=$1
else
  project_name="my_project"
fi 
 
# Ignore new project 
cat <<EOT >> .gitignore
$project_name/
EOT
 
git checkout -b $project_name
git add .gitignore 
git commit -m "Add $project_name to git ignore"

# Create project directory
mkdir $project_name
cd $project_name

# Initialize npm
npm init -y

# Install dependencies
npm install --save react react-dom
npm install --save-dev typescript webpack webpack-cli webpack-dev-server @types/react @types/react-dom ts-loader html-webpack-plugin css-loader style-loader sass-loader node-sass

# Install Storybook
yes | npx sb init --type react_scripts

# Install Jest
npm install --save-dev jest ts-jest @types/jest @testing-library/react @testing-library/jest-dom

# Create necessary directories
mkdir -p src/components src/stories src/__tests__ src/assets

# TypeScript configuration
cat <<EOT > tsconfig.json
{
  "compilerOptions": {
    "target": "es5",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "module": "esnext",
    "moduleResolution": "node",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": false,
    "jsx": "react-jsx"
  },
  "include": ["src"]
}
EOT

# Webpack configuration
cat <<EOT > webpack.config.js
const fs = require('fs');
const path = require('path');
const HtmlWebpackPlugin = require('html-webpack-plugin');
const config = require( './deploy/config.json' );
 
const htmlFileRegex = new RegExp("(src/pages/|src\\\\\\\\pages\\\\\\\\)", "ig");
let directories = config.entryPoints.pages.directory;

let htmlFiles = [];
let entryPoints = {}; 

while (directories.length > 0) {
  let directory = directories.pop();
  let dirContents = fs.readdirSync(directory).map(file => path.join(directory, file));

  htmlFiles.push(...dirContents.filter(file => file.endsWith('.html')));
  directories.push(...dirContents.filter(file => fs.statSync(file).isDirectory()));
}
 
htmlFiles.map(file => { 
    let name = file.replace( htmlFileRegex, "" );
    entryPoints[ name ] = path.resolve(
      __dirname, file.replace( ".html", ".tsx" )
    ); 
  }
); 

module.exports = ( env ) => {

  const environment = env.env;   
  const target = config.targets[ environment ];  
  const outputPath = target.outputPath;
  const publicPath = target.publicPath; 
  const assetModuleFilename = target.assetModuleFilename; 

  const clean = ( environment === 'dev' ) ? true : false; 

  return {
    stats: {
      loggingDebug: ["sass-loader"],
    },
    entry: entryPoints,
    output: {
      path: path.resolve(__dirname, outputPath),
      filename: '[name].js',
      clean: clean,
      assetModuleFilename: assetModuleFilename + './[name][ext]',
      publicPath: publicPath + '/'
    },
    devtool: 'source-map',
    module: {
      rules: [
        {
          test: /\.(js|jsx)$/,
          exclude: /node_modules/,
          use: ["babel-loader"]
        }, 
        {
          test: /\.tsx?$/,
          use: 'ts-loader',
          exclude: /node_modules/
        },
        {
          test:/\.scss$/,
          type: "asset/resource",
          generator: {
            filename: "assets/styles/[name].css",
          },
          use: [ { 
            loader : "sass-loader", 
            options: { 
              sourceMap: true, 
              sassOptions: {
                outputStyle: ( environment !== 'dev' ) ? "compressed" : undefined
              }
            } 
          } ],
        }, 
        {
          test: /\.(png|svg|jpg|gif|jpe?g|ico)$/,  
          type: 'asset/resource',
          generator: {
            filename: 'assets/images/[name][ext]'
          }
        },
        {
          test: /\.(woff|woff2)$/,  
          type: 'asset/resource',
          generator: {
            filename: 'assets/webfonts/[name][ext]'
          }
        }
      ],
    },
    resolve: {
      extensions: ['.tsx', '.ts', '.js', '.jsx'],
    },
    plugins: [
      ...htmlFiles.map(htmlFile => {  
          return new HtmlWebpackPlugin({
            template: htmlFile,
            filename: htmlFile.replace( htmlFileRegex, "" ), 
            chunks: [ htmlFile.replace( htmlFileRegex, "" ) ], 
            inject: false
          })
        }
      )
    ],
    devServer: {
      historyApiFallback: true,
    }
  }

}
EOT

# Create public folder and HTML file
mkdir src/pages
cat <<EOT > src/pages/index.html
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>React/Typescript Starter</title>
    <script src="../index.html.js" defer></script> 
    <link rel="stylesheet" href="assets/styles/SampleComponent.css">
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOT

# Jest configuration
cat <<EOT > jest.config.js
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'jsdom',
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  moduleNameMapper: {
    '\\.(scss)$': 'identity-obj-proxy',
  },
  transform: {
    '^.+\.tsx?$': 'ts-jest',
  },
  testRegex: '(/tests/.*|(\.|/)(test|spec))\.tsx?$',
    testPathIgnorePatterns: ['/node_modules/', '/.storybook/'],
    globals: {
      'ts-jest': {
        tsconfig: 'tsconfig.json',
      },
    },
  };
EOT

# Update package.json scripts
cat <<EOT > package.json
{
  "name": "$project_name",
  "version": "1.0.0",
  "description": "",
  "main": "index.js",
  "scripts": {
    "start": "npm run build && webpack serve --mode development --env env=dev --open --hot",
    "build": "webpack --mode development --env env=dev",
    "test": "jest",
    "storybook": "start-storybook -p 6006",
    "build-storybook": "build-storybook"
  },
  "keywords": [],
  "author": "",
  "license": "ISC",
  "dependencies": {
    $(node -p "JSON.stringify({...require('./package.json').dependencies}, null, 2).slice(1, -1)")
  },
  "devDependencies": {
    $(node -p "JSON.stringify({...require('./package.json').devDependencies}, null, 2).slice(1, -1)")
  }
}
EOT

# Create src/index.tsx,  src/components/SampleComponent.tsx, src/components/SampleComponent.scss, src/stories/SampleComponent.stories.tsx, and src/__tests__/SampleComponent.test.tsx
cat <<EOT >> src/pages/index.tsx
import React from 'react';
import ReactDOM from 'react-dom';
import SampleComponent from '../components/SampleComponent';

const App: React.FC = () => {
  return (
    <div>
      <SampleComponent text="Hello, React w/ Typescript, Storybook, and SCSS!" />
    </div>
  );
};

ReactDOM.render(
  <React.StrictMode>
    <App />
  </React.StrictMode>,
  document.getElementById('root')
);
EOT

cat <<EOT >> src/components/SampleComponent.tsx
import React from "react";
import "../styles/components/SampleComponent.scss";

export interface SampleComponentProps {
  text: string;
}

export const SampleComponent: React.FC<SampleComponentProps> = ({ text }) => {
  return <div className="sample-component">{text}</div>;
}; 

export default SampleComponent;
EOT
 
mkdir -p src/styles/components/
cat <<EOT >> src/styles/components/SampleComponent.scss
.sample-component {
  background-color: lightblue;
  padding: 1rem;
  border-radius: 4px;
}
EOT

cat <<EOT >> src/stories/SampleComponent.stories.tsx
import React from "react";
import { Story, Meta } from "@storybook/react";

import { SampleComponent, SampleComponentProps } from "../components/SampleComponent";

export default {
  title: "Example/SampleComponent",
  component: SampleComponent,
} as Meta;

const Template: Story<SampleComponentProps> = (args) => <SampleComponent {...args} />;

export const Default = Template.bind({});
Default.args = {
  text: "Hello, Storybook!",
};
EOT
 
cat <<EOT >> src/__tests__/SampleComponent.test.tsx
import React from "react";
import { render, screen } from "@testing-library/react";
import "@testing-library/jest-dom/extend-expect";
import SampleComponent from "../components/SampleComponent";

describe("SampleComponent", () => {
  test("renders with the correct text", () => {
    render(<SampleComponent text="Hello, Jest!" />);
    const element = screen.getByText("Hello, Jest!");
    expect(element).toBeInTheDocument();
  });
});
EOT

mkdir -p deploy
cat <<EOT >> deploy/example-config.json
{
  "targets": {
    "dev": { 
      "outputPath": "public",
      "publicPath" : "", 
      "assetModuleFilename" : "./public"
    }, 
    "prod": { 
      "outputPath": "dist",
      "publicPath" : "/dist", 
      "assetModuleFilename" : "./dist"
    }
  }, 
  "entryPoints" : {
    "pages" : {
      "directory" : ["src/pages/"] 
    }
  }
}
EOT

cp deploy/example-config.json deploy/config.json
 
cat <<EOT >> .gitignore
node_modules/
EOT

# Add Git
git init

# Done! 
echo "\n" 
echo "Project created successfully. Happy coding!"  

# Run project
npm run start