*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Library    DateTime
Resource    KeywordTC05.robot

*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC05_EditRequestAcademic/05_Data_EditRequestAcademic.xlsx
${URL}    http://localhost:8080/Academic_Services
${BROWSER}    Chrome
${rows}    48
${cols}    13


*** Test Cases ***
TC05: 05_Data_EditRequestAcademic
    [Documentation]    Test_05_Data_EditRequestAcademic
    [Tags]    Edit_Request_Academic
    Set Selenium Speed    1
    Go To Academic_Services    ${datatable}
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Run EditRequestAcademic    ${i} 
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document