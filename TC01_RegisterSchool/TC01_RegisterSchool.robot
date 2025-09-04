*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC01.robot






*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC01_RegisterSchool/01_Data_RegisterSchool.xlsx 
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${rows}    112
${cols}    18


*** Test Cases ***
TC01: 01_Data_RegisterSchool  
    [Documentation]    Test_01_Data_RegisterSchool
    [Tags]    Regsiter_School
    Go To Academic_Services    ${datatable}
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Run Register_School    ${i} 
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document
    
