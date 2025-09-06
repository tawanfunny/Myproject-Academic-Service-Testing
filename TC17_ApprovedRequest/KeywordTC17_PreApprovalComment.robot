*** Settings ***
Library    SeleniumLibrary
Resource    TC17_Data_PreApprovalComment.robot


*** Keywords ***
Setup Speed
    Set Selenium Speed    0.2


Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC17-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window

Run PreApprovalComment
    [Arguments]    ${row}
    ${ALLOW}=    Read Excel Cell    ${row}    9
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${row} - Allow: ${ALLOW}
    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Setup Speed
    ...    AND    Login As Lecturer
    ...    AND    Go To Approved Request    ${row}
    ...    AND    Fill Comment Form    ${row}
    ...    AND    Click Approved Button    ${row}
    ...    AND    Handle Submission Result    ${row}
    ...    AND    Validate And Write Result    ${row}
    ...    AND    Go To Logout
    
    Run Keyword If    '${ALLOW}' != 'Y'
    ...    Log To Console    Skipping row ${row} due to Allow = ${ALLOW}

Login As Lecturer
    Click Element    //button[contains(text(),'เข้าสู่ระบบ')]
    Click Element    //a[contains(text(),'เข้าสู่ระบบสำหรับอาจารย์')]
    Input Text    //input[@id='lecname']     sayan@gmaejo.mju.ac.th
    Input Text    //input[@id='lecpwd']   itscimju  
    Click Button    //body/form[1]/input[3]
    Handle Alert    ACCEPT 

Go To Approved Request
    [Arguments]    ${i}
    Click Element    //body/div[1]/div[1]/div[2]/a[1]
    Select From List By Value    css:#statusApprove    pending
    Click Element    //tbody/tr[${i}]/td[8]/a[1]/img[1]
    Sleep    2s

Fill Comment Form
    [Arguments]    ${i}
    ${PreApprovalComments}=    Read Excel Cell    ${i}    2
    ${PreApprovalComments}=    Evaluate    '' if $PreApprovalComments in ['None', '', None] else $PreApprovalComments
    Input Text    css:#commentReqDetail    ${PreApprovalComments}
    Sleep    3


Click Approved Button 
    [Arguments]    ${i}
    ${Action}=    Read Excel Cell    ${i}    3    
    Run Keyword If    '${Action}' == 'กดปุ่มไม่อนุมัติ'    Run Keyword And Ignore Error    Click Element    //button[@type='submit'][2]
    Run Keyword If    '${Action}' == 'กดปุ่มอนุมัติ'  Run Keyword And Ignore Error    Click Element    //button[@type='submit'][1]
    Sleep    2
    
    ${OC}=    Read Excel Cell    ${i}    4
    Run Keyword If    '${OC}' == 'กดปุ่ม Ok'    Handle Alert    ACCEPT
    Run Keyword If    '${OC}' == 'กดปุ่ม Cancel'    Handle Alert    DISMISS
    Sleep    2

    # Run Keyword If    '${OC}' == 'กดปุ่ม Cancel'
    # ...    Click Element    //div[3]//a[1]
    # Sleep    2


    # Run Keyword If    '${OC}' == 'กดปุ่ม Ok'
    # ...    Click Element    //body/div[1]/div[1]/div[2]/a[1]
    # Sleep    2


Handle Submission Result
    [Arguments]    ${i}
    ${alert_result}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
    Log To Console    Alert Status: ${alert_result[0]}
    Log To Console    Alert Text: ${alert_result[1]}

    Set Test Variable    ${alert_result}

    IF    '${alert_result[0]}' == 'PASS'
        ${ActualMessage}=    Set Variable    ${alert_result[1]}
    ELSE
        ${ActualMessage}=    Set Variable    Alert Not Found
        Capture Page Screenshot    TC17_ApprovedRequest/Screenshots_AlertNotFound/${i}_${ActualMessage}.png
    END
    Set Test Variable    ${ActualMessage}
    Sleep    2
    

Validate And Write Result
    [Arguments]    ${i}
    ${ExpectedResult}=    Read Excel Cell    ${i}    4
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=    Evaluate    '''${ActualMessage}'''.strip()

    Log To Console    Expected Result: ${ExpectedResult}
    Log To Console    Actual Message: ${ActualMessage}

    Write Excel Cell    ${i}    7   ${ActualMessage}

    ${compare_result}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    IF    ${compare_result}
        Write Excel Cell    ${i}    8    PASS
        Capture Page Screenshot    TC17_ApprovedRequest/Screenshots_Pass/${i}_Pass.png    
    ELSE
        Write Excel Cell    ${i}    8    FAIL
        Capture Page Screenshot    TC17_ApprovedRequest/Screenshots_Fail/${i}_Fail.png   
    END
    

    Run Keyword    Write Suggestion Based On Comparison    ${i}    ${ExpectedResult}    ${ActualMessage}

Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    11    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    11    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}



Go To Logout
    Click Element    //a[contains(text(),'ออกจากระบบ')]
    Sleep    1s



