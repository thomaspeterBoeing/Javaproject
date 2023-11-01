import { createElement } from 'lwc';
import PolicyFormat from 'c/policyFormat';

describe('c-policy-format', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    it('policy format should contain accordion section', () => {
        // Arrange
        const element = createElement('c-policy-format', {
            is: PolicyFormat
        });

        // Act
        document.body.appendChild(element);
        // Assert
        const accrd = element.shadowRoot.querySelectorAll('lightning-accordion-section')[0];
        expect(accrd).not.toBeNull();        
    });

    it('policy format component is accessible', async() => {
        // Arrange
        const element = createElement('c-policy-format', {
            is: PolicyFormat
        });
        // Act
        document.body.appendChild(element);
        // Assert        
        await expect(element).toBeAccessible();
    });
});