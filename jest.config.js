const { jestConfig } = require("@salesforce/sfdx-lwc-jest/config");
const setupFilesAfterEnv = jestConfig.setupFilesAfterEnv || [];
setupFilesAfterEnv.push("<rootDir>/jest-sa11y-setup.js");

module.exports = {
    ...jestConfig,
    modulePathIgnorePatterns: ["<rootDir>/.localdevserver"],
    moduleNameMapper: {
        "^lightning/select$": "<rootDir>/force-app/test/jest-mocks/lightning/select",
        "^lightning/modal$": "<rootDir>/force-app/test/jest-mocks/lightning/modal",
        "^lightning/messageService$": "<rootDir>/force-app/test/jest-mocks/lightning/messageService",
        "^lightning/platformShowToastEvent$": "<rootDir>/force-app/test/jest-mocks/lightning/platformShowToastEvent"
    },
    setupFilesAfterEnv,
    testTimeout: 10000
};
