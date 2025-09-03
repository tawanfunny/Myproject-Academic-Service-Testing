*** Settings ***
Library    SeleniumLibrary
Library    ExcelLibrary
Library    Collections
Library    String
Library    OperatingSystem
Library    DatabaseLibrary
Resource    KeywordTC17_Choice_ApprovedRequest.robot
Suite Setup    Set Selenium Speed    2

*** Variables ***
${datatable}    C:/test2/it/Project_Test_AcademicService/TC17_ApprovedRequest/17_Choice_ApprovedRequest.xlsx
${url}    http://localhost:8080/Academic_Services
${browser}    Chrome
${rows}    5
${cols}    10



*** Test Cases ***
TC17: 17_Choice_SelectRequest
    [Documentation]    Test_17_Choice_ApprovedRequest
    [Tags]    Choice_SelectRequest
    Go To Academic_Services    ${datatable}  
    
    FOR     ${i}    IN RANGE    2    ${rows}+1
        Login As Lecturer 
        Go To Approved Request    ${i}       
        Fill Comment Form    ${i}
        Read Expected Result From Excel    ${i}  
        Actions in the options and alerts section    ${i} 
        Read text from the screen and write it in Excel    ${i}
        Compare Result And Write Status    ${i}
        Go To Logout
    END
    
    Save Excel Document    ${datatable}
    Close Browser
    Close Current Excel Document