*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC07.robot




*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC07_RegisterStudent/07_Data_RegisterStudent.xlsx
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${rows}    76
${cols}    12


*** Test Cases ***
TC07: 07_Data_RegisterStudent
    [Documentation]    Test_07_Data_RegisterStudent
    [Tags]    Register_Student
    Go To Academic_Services    ${datatable}

    FOR    ${i}    IN RANGE    2    ${rows}+1
        Run Register_Student    ${i}  
    END
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document

    