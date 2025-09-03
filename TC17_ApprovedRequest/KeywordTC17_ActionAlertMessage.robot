*** Settings ***
Library    SeleniumLibrary
Resource    TC17_ActionAlertMessage_ApprovedRequest.robot


*** Keywords ***

Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC17-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Speed    0.1

Login As Lecturer
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับอาจารย์')]
    Input Text    //input[@id='lecname']     sayan@gmaejo.mju.ac.th
    Input Text    //input[@id='lecpwd']   itscimju  
    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT 

Go To Approved Request
    Click Element    //body/div[1]/div[1]/div[2]/a[1]
    Select From List By Value    css:#statusApprove    pending
    Click Element    //tbody/tr[13]/td[8]/a[1]/img[1]
    Sleep    2s

Fill Comment Form
    [Arguments]    ${i}
    ${PreApprovalComments}=    Read Excel Cell    ${i}    2
    ${PreApprovalComments}=    Evaluate    '' if $PreApprovalComments in ['None', '', None] else $PreApprovalComments
    Input Text    css:#commentReqDetail    ${PreApprovalComments}
    Sleep    3

Read Expected Result From Excel
    [Arguments]    ${i}
    ${ExpectedResult}=    Read Excel Cell    ${i}    4    
    Set Suite Variable    ${ExpectedResult}
    Log To Console    Expected Result: ${ExpectedResult}


Click Approved Button And Capture Alert
    [Arguments]    ${i}
    ${Action}=    Read Excel Cell    ${i}    3    
    Run Keyword If    '${Action}' == 'กดปุ่มไม่อนุมัติ'    Run Keyword And Ignore Error    Click Element    //button[@type='submit'][2]
    Run Keyword If    '${Action}' == 'กดปุ่มอนุมัติ'  Run Keyword And Ignore Error    Click Element    //button[@type='submit'][1]
    Sleep    3
    ${status}    ${message}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
    Run Keyword If    '${status}' == 'PASS'    Set Suite Variable    ${ActualMessage}    ${message}
    Run Keyword If    '${status}' != 'PASS'    Set Suite Variable    ${ActualMessage}    Alert Not Found
    Scroll Element Into View   //tbody/tr[26]/td[8]/a[1]/img[1]
    Capture Page Screenshot    Project_Test_AcademicService/TC17_ApprovedRequest/Screenshots_ActionAlertMessage/${i}_ActionAlert.png
    Write Excel Cell    ${i}    6    ${ActualMessage}

    

Compare And Write Result To Excel
    [Arguments]    ${i}
    ${is_pass}=    Run Keyword And Return Status    Should Be Equal    ${ActualMessage}    ${ExpectedResult}
    Run Keyword If    ${is_pass}    Write Excel Cell    ${i}    7    Pass
    Run Keyword If    not ${is_pass}    Write Excel Cell    ${i}    7    Fail

    Run Keyword    Write Suggestion Based On Comparison    ${i}    ${ExpectedResult}    ${ActualMessage}


Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    9    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    9    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}



Go To Logout
    Click Element    //a[contains(text(),'ออกจากระบบ')]
    Sleep    1s



