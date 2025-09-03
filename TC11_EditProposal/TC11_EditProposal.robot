*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Resource    KeywordTC11_EditProposal.robot


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC11_EditProposal/11_Data_EditProposal.xlsx
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${rows}    144
${cols}    25

*** Test Cases ***
TC11: 11_Data_EditAddProposal
    [Documentation]    Test_11_Data_EditAddProposal
    [Tags]    Data_EditAddProposal
    Set Selenium Speed    2.5
    Go To Academic_Services    ${datatable}
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Run EditAddProposal    ${i}
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document