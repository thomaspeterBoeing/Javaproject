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

const SEARCH_SUCCESS = require('./data/searchSuccess.json');
const PHONE_NUMBER_RESULTS = require('./data/phoneNumberResults.json');

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
        //Create search criteria object      
        const searchCriteria = {
			'ssn' 			: undefined,
			'policyNumber' 	: null,
			'firstName' 	: 'First',
			'lastName' 		: 'Last',
			'dateOfBirth' 	: null,
			'state' 		: null,
			'zipCode' 		: '28262',
			'phoneNumber' 	: null
		};
		let APEX_PARAMETERS = searchCriteria;//Set apex parameters
        search.mockResolvedValue(SEARCH_SUCCESS);//Set mock resolved value for search APEX method
        
        //Create consumer search component
        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        //Add consmer search component to page
        document.body.appendChild(element);

        //Query all search inputs
        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox'),
            inputFN, inputLN, inputPC;

        //Loop through all inputs found
        for(let inpt of allInputs){
            inpt.checkValidity = jest.fn().mockReturnValue(true);//Make current input valid
            if(inpt.name=='firstName'){//Check if current input is first name
               inputFN = inpt;//Set current input value to inputFN variable
            }
            else if(inpt.name=='lastName'){//Check if current input is last name
               inputLN = inpt;//Set current input value to inputLN variable
            }
            else if(inpt.name=='postalCode'){//Check if current input is postal code
                inputPC = inpt;//Set current input value to inputPC variable
            }
        }
        
        inputFN.value = 'First ';//Update first name input value
        inputFN.dispatchEvent(new CustomEvent('change'));//onChange event for first name field
        
        inputLN.value = 'Last ';//Update last name input value
        inputLN.dispatchEvent(new CustomEvent('change'));//onChange event for last name field
        
        inputPC.value = '28262';//Update postal code input value
        inputPC.dispatchEvent(new CustomEvent('change'));//onChange event for postal code field
               
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');//Query search button               
        buttonEl.click();//Click on search button
        
        // Wait for any asynchronous DOM updates
        await flushPromises(); 
        expect(search).toHaveBeenCalled();//search APEX method should have been called      
        expect(search.mock.calls[0][0]).toEqual({kvpSearchCriteria: APEX_PARAMETERS});//The search critera for search method should be equal to APEX_PARAMETERS
    });


    it('valid search combination with one required field null should throw an error-1', async() => {   
        search.mockResolvedValue(SEARCH_SUCCESS);//Set mock resolved value for search APEX method

        const element = createElement('c-consumer-search', {//Create consumer search component
            is: consumerSearch
        });

        document.body.appendChild(element);//Add consmer search component to page

        //Query all input elements from search page
        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox'),
            inputFN,inputLN,inputSt;

        for(let inpt of allInputs ){//Loop through each input that was found
            inpt.checkValidity = jest.fn().mockReturnValue(true);//Make current input valid  
            if(inpt.name=='firstName'){//Check if current input is first name
                inputFN = inpt;//Set current input value to inputFN variable
            }
            else if(inpt.name=='lastName'){//Check if current input is last name
                inputLN = inpt;//Set current input value to inputLN variable
            }
            else if(inpt.name=='state'){//Check if current input is state
                inputSt = inpt;//Set current input value to inputSt variable
            }
        }
        
        inputFN.value = 'First';//Update value of first name    
        inputLN.value = '';//Update value of last name
        inputSt.value = 'NC';//Update value of state
      
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');//Query search button            
        buttonEl.click();//Click on search button

        let errDisp = element.shadowRoot.querySelector('div[data-id=errorWrapper]');//Query error display element               
        
        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(search).not.toHaveBeenCalled();//search APEX method should not have been called
        expect(errDisp.textContent).toEqual('Invalid Search Combination');//Error display element should display the correct message     
    });


    it('invalid search combination should throw an error-2', async() => {
        search.mockResolvedValue(SEARCH_SUCCESS);//Set mock resolved value for search APEX method

        const element = createElement('c-consumer-search', {//Create consumer search method
            is: consumerSearch
        });

        document.body.appendChild(element);//Add consumer search component to page

        //Query all search input elements
        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox'),
            inputFN, inputPc;

        for(let inpt of allInputs ){//Loop through all inputs found
            inpt.checkValidity = jest.fn().mockReturnValue(true);//Make the current input valid   
            if(inpt.name=='firstName'){//Check if current input is first name
               inputFN = inpt;//Set the current input value to inputFN variable
            }
            else if(inpt.name=='postalCode'){//Check if current input is postal code
                inputPc = inpt;//Set the current input value to inputPc variable
            }
        }
        
        inputFN.value = 'First';//Update first name value
        inputPc.value = '28262';//Update postal code value

        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');//Query search button               
        buttonEl.click();//Click on search button

        let errDisp = element.shadowRoot.querySelector('div[data-id=errorWrapper]');//Query error display element                
        
        // Wait for any asynchronous DOM updates
        await flushPromises();     
        expect(search).not.toHaveBeenCalled();//search APEX method should have been called
        expect(errDisp.textContent).toEqual('Invalid Search Combination');//The error display element should display the correct message      
    });

    it('search combination- field is invalid- should throw an error-3', async() => {
        search.mockResolvedValue(SEARCH_SUCCESS);//Mock resolved value for search APEX method

        const element = createElement('c-consumer-search', {//Create consumer search component
            is: consumerSearch
        });

        document.body.appendChild(element);//Add consumer search component to page

        //Query all search input elements
        let allInputs = element.shadowRoot.querySelectorAll('lightning-input'),
            inputSSN;

        for(let inpt of allInputs ){//Loop through all inputs that were found
            inpt.checkValidity = jest.fn().mockReturnValue(true);//Make current input valid
            if(inpt.name=='ssn'){//Check if current input is ssn
                inputSSN = inpt;//Set current input value to inputSSN variable
                inpt.checkValidity = jest.fn().mockReturnValue(false);//Make current input invalid
            }            
        }
        
        inputSSN.value = 'test';//Update value of ssn field    
        inputSSN.dispatchEvent(new CustomEvent('change'));//onChange event for ssn field   

        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');//Query search button             
        buttonEl.click();//Click on search button              
        
        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(search).not.toHaveBeenCalled();//search APEX method should not have been called because of errors with search inputs
    });
   

    it('click policy format button should open policy format', async() => {
        //Creating parameters for modal
        const MODAL_PARAMS =
        '{ size: \'small\', description: \'MiscModal displays the message in a popup\',header: \'The modal header\',content: \'The modal content\',}';

        //Create consumer search element
        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        document.body.appendChild(element);//Add consumer search element to page
        LightningModal.open = jest.fn().mockResolvedValue(MODAL_PARAMS);//Open policy format modal
        
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnPolicyFormat]');//Query policy format link               
        buttonEl.click();//Click on policy format link

        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(LightningModal.open).toHaveBeenCalledTimes(1);//LightingModel.open should have been only called once
        
    });


    it('sutherland inbound call should search consumers based on the phone number', async() => {   
        //Setting mock values for APEX methods    
        search.mockResolvedValue(SEARCH_SUCCESS);
        checkPhoneExclusionFlag.mockResolvedValue(false);

        //Create consumer search component
        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

         // Emit data from @wire
         CurrentPageReference.emit(mockCurrentPageReference);

        //Add consumer search component to page
        document.body.appendChild(element);
        
        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(search).toHaveBeenCalled();//search APEX method should have been called
        expect(checkPhoneExclusionFlag).toHaveBeenCalled();//checkPhoneExclusionFlag APEX method should have been called
    });

    it('sutherland inbound call not search when number is excluded', async() => {   
        //Setting mock values for APEX methods        
        search.mockResolvedValue(SEARCH_SUCCESS);
        checkPhoneExclusionFlag.mockResolvedValue(true);

        //Create consumer search component
        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

         // Emit data from @wire
         CurrentPageReference.emit(mockCurrentPageReference);

        //Add consumer search component to page
        document.body.appendChild(element);
        
        // Wait for any asynchronous DOM updates
        await flushPromises();
        expect(search).not.toHaveBeenCalled();//search APEX method should not have been callled
        
    });

    it('datatable-should display the same number of rows', async() => {
        search.mockResolvedValue(SEARCH_SUCCESS);//Mock results from search service

        const element = createElement('c-consumer-search', {//Create consumer search component
            is: consumerSearch
        });

        document.body.appendChild(element);//Add consumer search component to page

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox');//Query all input fields and dropdowns
        let inputFN; 
        let inputLN; 
        let inputPC;

        for(let inpt of allInputs ){
            inpt.checkValidity = jest.fn().mockReturnValue(true);//Make current input valid   
            if(inpt.name=='firstName'){//Current input field is first name
               inputFN = inpt;//Assign current input value to inputFN variable
            }
            else if(inpt.name=='lastName'){//Current input field is last name
               inputLN = inpt;//Assign current input value to inputLN variable
            }
            else if(inpt.name=='postalCode'){//Current input field is postal code
                inputPC = inpt;//Assign current input value to inputPC variable
            }
        }
        
        inputFN.value = 'First ';//Update value for first name field
        inputFN.dispatchEvent(new CustomEvent('change'));//onChange event for first name field
        
        inputLN.value = 'Last ';//Update value for last name field
        inputLN.dispatchEvent(new CustomEvent('change'));//onChange event for last name field
        
        inputPC.value = '11111';//Update value for postal code field
        inputPC.dispatchEvent(new CustomEvent('change'));//onChange event for postal code field

        
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');//Query search button               
        buttonEl.click();//Click on search button
        
        // Wait for any asynchronous DOM updates
        await flushPromises();        
        // Assert        
        let rows = element.shadowRoot.querySelectorAll('tr[class=dummy]');           
        expect(search).toHaveBeenCalled();        
        expect(rows.length).toEqual(SEARCH_SUCCESS.results.length);

    });

    it('Input fields should format correctly', async() => {
        //Create consumer search component
        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        //Add consumer search componet to page
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises(); 

        let ssn = element.shadowRoot.querySelector('lightning-input[data-id=ssn]');//Query ssn input field
        ssn.value = '111111111';//Update the value for ssn field
        ssn.dispatchEvent(new CustomEvent('change'));//onChange event for ssn field

        let phone = element.shadowRoot.querySelector('lightning-input[data-id=phone]');//Query phone input field
        phone.value = '1111111111';//Update the value for phone field
        phone.dispatchEvent(new CustomEvent('change'));//onChange event for phone field

        let postalCode = element.shadowRoot.querySelector('lightning-input[data-id=postalCode]');//Query postal code input field
        postalCode.value = '111111111';//Update the value for postal code field
        postalCode.dispatchEvent(new CustomEvent('change'));//onChange event for postal code field

        // Wait for any asynchronous DOM updates
        await flushPromises(); 
        ssn = element.shadowRoot.querySelector('lightning-input[data-id=ssn]');//Re-query ssn input field
        phone = element.shadowRoot.querySelector('lightning-input[data-id=phone]');//Re-query phone input field
        postalCode = element.shadowRoot.querySelector('lightning-input[data-id=postalCode]');//Re-query postal code input field
        expect(ssn.value).toEqual('111-11-1111');//SSN should be in correct format
        expect(phone.value).toEqual('(111) 111-1111');//Phone should be in correct format
        expect(postalCode.value).toEqual('11111-1111');//Postal code should be in correct format
    });

    it('DOB should format correctly in search results', async() => {
        //Mock results from search service
        search.mockResolvedValue(SEARCH_SUCCESS);

        //Create consumer search component
        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        //Add consumer search component to page
        document.body.appendChild(element);

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox');//Query all input fields and dropdowns
        let inputFN; 
        let inputLN; 
        let inputPC;

        for(let inpt of allInputs ){
            inpt.checkValidity = jest.fn().mockReturnValue(true);//Make current input valid   
            if(inpt.name=='firstName'){//Current input field is first name
               inputFN = inpt;//Assign current input value to inputFN variable
            }
            else if(inpt.name=='lastName'){//Current input field is last name
               inputLN = inpt;//Assign current input value to inputLN variable
            }
            else if(inpt.name=='postalCode'){//Current input field is postal code
                inputPC = inpt;//Assign current input value to inputPC variable
            }
        }
        
        inputFN.value = 'First ';//Update value for first name field
        inputFN.dispatchEvent(new CustomEvent('change'));//onChange event for first name field
        
        inputLN.value = 'Last ';//Update value for last name field
        inputLN.dispatchEvent(new CustomEvent('change'));//onChange event for last name field
        
        inputPC.value = '11111';//Update value for postal code field
        inputPC.dispatchEvent(new CustomEvent('change'));//onChange event for postal code field

        
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');//Query search button               
        buttonEl.click();//Click on search button
        
        // Wait for any asynchronous DOM updates
        await flushPromises(); 

        let dobs = element.shadowRoot.querySelectorAll('td[data-id=dateOfBirth');//Query date of birth elements from search results
        expect(dobs.length).toEqual(2);//There should be 2 rows in search results
        expect(dobs[0].textContent).toEqual('01/03/2024');//Row 1 date of birth should be in correct format
        expect(dobs[1].textContent).toEqual('01/04/2024');//Row 2 date of birth should be in correct format
    });

    it('Search results should display the correct phone number in the correct format', async() => {
        search.mockResolvedValue(PHONE_NUMBER_RESULTS);//Mock results from search service

        const element = createElement('c-consumer-search', {//Create consumer search component
            is: consumerSearch
        });

        document.body.appendChild(element);//Add consumer search component to page

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox');//Query all input fields and dropdowns
        let inputFN; 
        let inputLN; 
        let inputPC;

        for(let inpt of allInputs ){
            inpt.checkValidity = jest.fn().mockReturnValue(true);//Make current input valid   
            if(inpt.name=='firstName'){//Current input field is first name
               inputFN = inpt;//Assign current input value to inputFN variable
            }
            else if(inpt.name=='lastName'){//Current input field is last name
               inputLN = inpt;//Assign current input value to inputLN variable
            }
            else if(inpt.name=='postalCode'){//Current input field is postal code
                inputPC = inpt;//Assign current input value to inputPC variable
            }
        }
        
        inputFN.value = 'First ';//Update value for first name field
        inputFN.dispatchEvent(new CustomEvent('change'));//onChange event for first name field
        
        inputLN.value = 'Last ';//Update value for last name field
        inputLN.dispatchEvent(new CustomEvent('change'));//onChange event for last name field
        
        inputPC.value = '11111';//Update value for postal code field
        inputPC.dispatchEvent(new CustomEvent('change'));//onChange event for postal code field

        
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');//Query search button               
        buttonEl.click();//Click on search button
        
        // Wait for any asynchronous DOM updates
        await flushPromises(); 

        let phones = element.shadowRoot.querySelectorAll('td[data-id=phoneDisplay');//Query phone display elements from search results
        expect(phones.length).toEqual(3);//There should be 3 rows in search results
        expect(phones[0].textContent).toEqual('(111) 111-1111');//Row 1 phone display should be in correct format. Phone should be home phone value
        expect(phones[1].textContent).toEqual('(222) 222-2222');//Row 2 phone display should be in correct format. Phone should be mobile phone value
        expect(phones[2].textContent).toEqual('(333) 333-3333');//Row 3 phone display should be in correct format. Phone should be other phone value
    });

    it('Table should sort when table header is clicked', async() => {
        search.mockResolvedValue(SEARCH_SUCCESS);//Mock results from search service

        const element = createElement('c-consumer-search', {//Create consumer search component
            is: consumerSearch
        });

        document.body.appendChild(element);//Add consumer search component to page

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox');//Query all input fields and dropdowns
        let inputFN; 
        let inputLN; 
        let inputPC;

        for(let inpt of allInputs ){
            inpt.checkValidity = jest.fn().mockReturnValue(true);//Make current input valid   
            if(inpt.name=='firstName'){//Current input field is first name
               inputFN = inpt;//Assign current input value to inputFN variable
            }
            else if(inpt.name=='lastName'){//Current input field is last name
               inputLN = inpt;//Assign current input value to inputLN variable
            }
            else if(inpt.name=='postalCode'){//Current input field is postal code
                inputPC = inpt;//Assign current input value to inputPC variable
            }
        }
        
        inputFN.value = 'First ';//Update value for first name field
        inputFN.dispatchEvent(new CustomEvent('change'));//onChange event for first name field
        
        inputLN.value = 'Last ';//Update value for last name field
        inputLN.dispatchEvent(new CustomEvent('change'));//onChange event for last name field
        
        inputPC.value = '11111';//Update value for postal code field
        inputPC.dispatchEvent(new CustomEvent('change'));//onChange event for postal code field

        
        // Select button for executing Apex         
        const buttonEl = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');//Query search button               
        buttonEl.click();//Click on search button
        
        // Wait for any asynchronous DOM updates
        await flushPromises(); 

        let nameHeader = element.shadowRoot.querySelector('th a');//Select the first header in the table
        nameHeader.click();//onClick event for name header

        // Wait for any asynchronous DOM updates
        await flushPromises(); 
        let fullName = element.shadowRoot.querySelector('td[data-id=fullName] lightning-button');//Query the first row name element from search results
        expect(fullName.label).toEqual(SEARCH_SUCCESS.results[1].firstName + ' ' + SEARCH_SUCCESS.results[1].lastName);//Name of first row in results should be equal to the full name in the first row of SEARCH_SUCCESS
    });

    it('Clear button should clear results and input fields', async() => {
        search.mockResolvedValue(SEARCH_SUCCESS);//Mock results from search service

        const element = createElement('c-consumer-search', {//Create consumer search component
            is: consumerSearch
        });

        document.body.appendChild(element);//Add consumer search component to page

        let allInputs = element.shadowRoot.querySelectorAll('lightning-input, lightning-combobox');//Query all input fields and dropdowns
        let inputSSN;

        for(let inpt of allInputs ){//Loop through all inputs found
            inpt.checkValidity = jest.fn().mockReturnValue(true);//Make current input valid   
            if(inpt.name=='ssn'){//Current input field is first name
                inputSSN = inpt;//Assign current input value to inputFN variable
            }
        }
        
        inputSSN.value = '111111111';//Update value for first name field
        inputSSN.dispatchEvent(new CustomEvent('change'));//onChange event for first name field
        
        const searchBtn = element.shadowRoot.querySelector('lightning-button[data-id=btnSearch]');//Query search button               
        searchBtn.click();//Click on search button

        // Wait for any asynchronous DOM updates
        await flushPromises();  
        let newBtn = element.shadowRoot.querySelector('lightning-button[data-id=btnNew]');//Query new button
        let rows = element.shadowRoot.querySelectorAll('tr[class=dummy]');//Query results
        let ssn = element.shadowRoot.querySelector('lightning-input[data-id=ssn]');//Query ssn input field
        await expect(newBtn).toBeAccessible();//The New button should be accessible since we had a successful response after clicking search button
        expect(ssn.value).toEqual(inputSSN.value);//The ssn input value should be equal to the value before clicking the search button
        expect(rows.length).toEqual(SEARCH_SUCCESS.results.length);//The number of rows in search results, should be equal to the number of rows in SEARCH_SUCCESS
     
        const clearBtn = element.shadowRoot.querySelector('lightning-button[data-id=btnClear]');//Query clear button               
        clearBtn.click();//Click on clear button
        
        // Wait for any asynchronous DOM updates
        await flushPromises();
        ssn = element.shadowRoot.querySelector('lightning-input[data-id=ssn]');//Re-query ssn input field after clicking the clear button
        newBtn = element.shadowRoot.querySelector('lightning-button[data-id=btnNew]');//Re-query new button
        rows = element.shadowRoot.querySelectorAll('tr[class=dummy]');//Re-query the rows after clicking the clear button
        expect(newBtn).toBeNull();//The new button should not be accessible
        expect(ssn.value).toBeNull();//The value of the ssn input field should be null
        expect(rows.length).toEqual(0);//There should no rows in search results
    });

    it('is accessible', async() => {
        //Create consumer search component
        const element = createElement('c-consumer-search', {
            is: consumerSearch
        });

        document.body.appendChild(element);//Add consumer search component to page      
        await expect(element).toBeAccessible();//Consumer search element should be accessible
    });
});