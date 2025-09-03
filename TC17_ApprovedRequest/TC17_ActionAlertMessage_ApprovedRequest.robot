*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC17_ActionAlertMessage.robot


*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC17_ApprovedRequest/17_ActionAlertMessage_ApprovedRequest.xlsx
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${rows}    3
${cols}    8



*** Test Cases ***
TC17: 17_ActionAlertMessage_ApprovedRequest
    [Documentation]    Test_17_ActionAlertMessage_ApprovedRequest
    [Tags]    ActionAlertMessage_ApprovedRequest
    Set Selenium Speed    5
    Go To Academic_Services    ${datatable}
    FOR    ${i}    IN RANGE    2    ${rows}+1
        Login As Lecturer
        Go To Approved Request
        Fill Comment Form    ${i}    
        Read Expected Result From Excel    ${i}     
        Click Approved Button And Capture Alert    ${i}
        Compare And Write Result To Excel    ${i}
        Go To Logout
    END
    
    
    
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document