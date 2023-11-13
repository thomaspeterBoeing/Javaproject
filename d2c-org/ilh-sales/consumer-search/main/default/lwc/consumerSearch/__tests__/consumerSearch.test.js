import { createElement } from 'lwc';
import consumerSearch from 'c/consumerSearch';
import search from '@salesforce/apex/ConsumerSearchController.search';
import checkPhoneExclusionFlag from '@salesforce/apex/ConsumerSearchController.checkPhoneExclusionFlag';
import LightningModal from 'lightning/modal';
import { CurrentPageReference } from 'lightning/navigation';

const mockCurrentPageReference = require('./data/CurrentPageReference.json');

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/ConsumerSearchController.search',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

jest.mock(
    '@salesforce/apex/ConsumerSearchController.checkPhoneExclusionFlag',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

const SEARCH_SUCCESS = {
    results: [
        {        
            firstName: 'Amy',
            dateOfBirth: '1/1/1980',
            street: '123 Main St',
            city: 'Charlotte',
            state:'NC',
            postalCode:'NC',
            phone:'123-123-1234',
            personId: '11111111'
        },
        {
            firstName: 'Jimy',
            dateOfBirth: '1/1/1980',
            street: '123 Main St',
            city: 'Colombia',
            state:'SC',
            postalCode:'SC',
            phone:'123-123-1234',
            personId: '22222222'
        }
    ]
};

describe('c-consumer-search', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    async function flushPromises() {
        return Promise.resolve();
    }

    it('All Text inputs should be trimmed by the formatter', async() => {        
        const searchCriteria = {
			"ssn" 			: null,
			"policyNumber" 	: null,
			"firstName" 	: "First",
			"lastName" 		: "Last",
			"dateOfBirth" 	: null,
			"state" 		: null,
			"zipCode" 		: "28262",
			"phoneNumber" 	: null
		};
		let APEX_PARAMETERS = searchCriteria;
        // Arrange
        search.mockResolvedValue(SEARCH_SUCCESS);
        
        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        // Act
        document.body.appendChild(element);

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox'),
            inputFN, inputLN, inputPC;

        for(let inpt of allInputs){
            inpt.checkValidity = jest.fn().mockReturnValue(true);   
            if(inpt.name=="firstName"){
               inputFN = inpt;
            }
            else if(inpt.name=="lastName"){
               inputLN = inpt;
            }
            else if(inpt.name=="postalCode"){
                inputPC = inpt;
            }
        }
        
        inputFN.value = "First ";
        inputFN.dispatchEvent(new CustomEvent('change'));
        
        inputLN.value = "Last ";
        inputLN.dispatchEvent(new CustomEvent('change'));
        
        inputPC.value = "28262";
        inputPC.dispatchEvent(new CustomEvent('change'));
        
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');               
        buttonEl.click();
        
        // Wait for any asynchronous DOM updates
        await flushPromises();        
        // Assert        
        expect(search).toHaveBeenCalled();          
        expect(search.mock.calls[0][0]).toEqual({ 
            kvpSearchCriteria: APEX_PARAMETERS
        });

    });


    it('valid search combination with one required field null should throw an error-1', async() => {   
        // Arrange
        search.mockResolvedValue(SEARCH_SUCCESS);

        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        // Act
        document.body.appendChild(element);

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox'),
            inputFN,inputLN,inputSt;

        for(let inpt of allInputs ){
            inpt.checkValidity = jest.fn().mockReturnValue(true);   
            if(inpt.name=="firstName"){
               inputFN = inpt;
            }
            else if(inpt.name=="lastName"){
               inputLN = inpt;
            }
            else if(inpt.name=="state"){
               inputSt = inpt;
            }
        }
        
        inputFN.value = "First";        
        inputLN.value = "";
        inputSt.value = "NC";

        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');               
        buttonEl.click();

        let errDisp = element.shadowRoot.querySelector('div[data-id=errorWrapper]');               
        
        // Wait for any asynchronous DOM updates
        await flushPromises();        
        // Assert        
        expect(search).not.toHaveBeenCalled();
        expect(errDisp.textContent).toEqual("Invalid Search Combination");        
    });


    it('invalid search combination should throw an error-2', async() => {   
        // Arrange
        search.mockResolvedValue(SEARCH_SUCCESS);

        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        // Act
        document.body.appendChild(element);

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox'),
            inputFN, inputPc;

        for(let inpt of allInputs ){
            inpt.checkValidity = jest.fn().mockReturnValue(true);   
            if(inpt.name=="firstName"){
               inputFN = inpt;
            }
            else if(inpt.name=="postalCode"){
                inputPc = inpt;
            }
        }
        
        inputFN.value = "First";
        inputPc.value = "28262";
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');               
        buttonEl.click();

        let errDisp = element.shadowRoot.querySelector('div[data-id=errorWrapper]');                
        
        // Wait for any asynchronous DOM updates
        await flushPromises();        
        // Assert        
        expect(search).not.toHaveBeenCalled();
        expect(errDisp.textContent).toEqual("Invalid Search Combination");        
    });

    it('search combination- field is invalid- should throw an error-3', async() => {   
        // Arrange
        search.mockResolvedValue(SEARCH_SUCCESS);

        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        // Act
        document.body.appendChild(element);

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input'),
            inputSSN;

        for(let inpt of allInputs ){
            inpt.checkValidity = jest.fn().mockReturnValue(true);   
            if(inpt.name=="ssn"){
                inputSSN = inpt;
                inpt.checkValidity = jest.fn().mockReturnValue(false);
            }            
        }
        
        inputSSN.value = "test";     
        inputSSN.dispatchEvent(new CustomEvent('change'));   
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');               
        buttonEl.click();

        let errDisp = element.shadowRoot.querySelector('p[data-id=errorDisplay]');               
        
        // Wait for any asynchronous DOM updates
        await flushPromises();    
        
        // Assert        
        expect(search).not.toHaveBeenCalled();
        if (errDisp) {
            expect(errDisp.innerText).toEqual("Invalid Input");
        }        
    });
   

    it('click policy format button should open policy format', async() => {   
        // Arrange
        //searchCPS.mockResolvedValue(SEARCH_SUCCESS);
        const MODAL_PARAMS =
        "{ size: 'small', description: 'MiscModal displays the message in a popup',header: 'The modal header',content: 'The modal content',}";

        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        // Act
        document.body.appendChild(element);
        LightningModal.open = jest.fn().mockResolvedValue(MODAL_PARAMS);
        
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnPolicyFormat]');               
        buttonEl.click();

        // Wait for any asynchronous DOM updates
        await flushPromises();        
        // Assert  
        expect(LightningModal.open).toHaveBeenCalledTimes(1);
        
    });


    it('sutherland inbound call should search consumers based on the phone number', async() => {   
        // Arrange        
        search.mockResolvedValue(SEARCH_SUCCESS);
        checkPhoneExclusionFlag.mockResolvedValue(false);

        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

         // Emit data from @wire
         CurrentPageReference.emit(mockCurrentPageReference);

        // Act
        document.body.appendChild(element);
        
        // Wait for any asynchronous DOM updates
        await flushPromises();        
        // Assert  
        expect(search).toHaveBeenCalled();
        expect(checkPhoneExclusionFlag).toHaveBeenCalled();
    });

    it('sutherland inbound call not search when number is excluded', async() => {   
        // Arrange        
        search.mockResolvedValue(SEARCH_SUCCESS);
        checkPhoneExclusionFlag.mockResolvedValue(true);

        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

         // Emit data from @wire
         CurrentPageReference.emit(mockCurrentPageReference);

        // Act
        document.body.appendChild(element);
        
        // Wait for any asynchronous DOM updates
        await flushPromises();        
        // Assert  
        expect(search).not.toHaveBeenCalled();
        
    });

    it('datatable-should display the same number of rows', async() => {      
        // Arrange
        search.mockResolvedValue(SEARCH_SUCCESS);

        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        // Act
        document.body.appendChild(element);

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox');
        let inputFN; 
        let inputLN; 
        let inputPC;

        for(let inpt of allInputs ){
            inpt.checkValidity = jest.fn().mockReturnValue(true);   
            if(inpt.name=="firstName"){
               inputFN = inpt;
            }
            else if(inpt.name=="lastName"){
               inputLN = inpt;
            }
            else if(inpt.name=="postalCode"){
                inputPC = inpt;
            }
        }
        
        inputFN.value = "First ";
        inputFN.dispatchEvent(new CustomEvent('change'));
        
        inputLN.value = "Last ";
        inputLN.dispatchEvent(new CustomEvent('change'));
        
        inputPC.value = "11111";
        inputPC.dispatchEvent(new CustomEvent('change'));

        
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');               
        buttonEl.click();
        
        // Wait for any asynchronous DOM updates
        await flushPromises();        
        // Assert        
        let rows = element.shadowRoot.querySelectorAll('tr[class=dummy]');           
        expect(search).toHaveBeenCalled();        
        expect(rows.length).toEqual(SEARCH_SUCCESS.results.length);

    });


    it('is accessible', async() => {
        // Arrange
        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        // Act
        document.body.appendChild(element);
        // Assert        
        await expect(element).toBeAccessible();
    });
});