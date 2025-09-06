*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC17_PreApprovalComment.robot


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC17_ApprovedRequest/17_Data_PreApprovalComment.xlsx
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${rows}    10
${cols}    11



*** Test Cases ***
TC17: 17_Data_PreApprovalComment
    [Documentation]    Test_17_Data_PreApprovalComment
    [Tags]    PreApprovalComment   
    
    Go To Academic_Services    ${datatable}

    FOR    ${i}    IN RANGE    2    ${rows}+1
        Run PreApprovalComment    ${i}
    END
    
    
    
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document