import { createElement } from 'lwc';
import ILHSalesConsumerCreationUpdate from 'c/iLHSalesConsumerCreationUpdate';

describe('c-i-l-h-sales-consumer-creation-update', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('TODO: test case generated by CLI command, please fill in test logic', () => {
        // Arrange
        const element = createElement('c-i-l-h-sales-consumer-creation-update', {
            is: IlhSalesConsumerCreationUpdate
        });

        // Act
        document.body.appendChild(element);

        // Assert
        // const div = element.shadowRoot.querySelector('div');
        expect(1).toBe(1);
    });
});