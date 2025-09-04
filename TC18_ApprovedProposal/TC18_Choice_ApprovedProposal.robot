*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC18_Choice_ApprovedProposal.robot



*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC18_ApprovedProposal/18_Choice_ApprovedProposal.xlsx
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${rows}    3
${cols}    8



*** Test Cases ***
TC18: 18_Choice_ApprovedProposal
    Go To Academic_Services    ${datatable}
    [Documentation]    Test_18_Choice_ApprovedProposal
    [Tags]    Choice_ApprovedProposal
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Setup Speed
        Login As Lecturer    
        Go To Approved Proposal    ${i}
        Fill Comment Form    ${i}    
        Read Expected Result From Excel    ${i}     
        Click Approved Button And Capture Alert    ${i}
        Read text from the screen and write it in Excel    ${i}
        Compare And Write Result To Excel    ${i}
        Go To Logout
    END
    
    
    
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document