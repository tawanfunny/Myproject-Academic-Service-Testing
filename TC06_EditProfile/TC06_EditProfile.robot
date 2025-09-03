*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC06.robot



*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC06_EditProfile/06_Data_EditProfile.xlsx   
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${rows}    112
${cols}    16


*** Test Cases ***
TC06: 06_Data_RegisterSchool
    [Documentation]    Test_06_Data_EditProfile
    [Tags]    Edit_Profile
    Set Selenium Speed    1
    Go To Academic_Services    ${datatable}
    Go To Login Page
    Login As Member
    
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Run EditFrofile    ${i} 
    END

    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document
    
