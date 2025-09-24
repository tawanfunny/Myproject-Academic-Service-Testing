*** Settings ***
Library    SeleniumLibrary
Resource    TC18_Choice_ApprovedProposal.robot


*** Keywords ***
Setup Speed
    Set Selenium Speed    0.4

Update Status Data In DB
    ${query}=    Set Variable    UPDATE db_academic_services.proposal SET proposalStatus = 'รออนุมัติ';
    Execute Sql String    ${query}
     

Go To Academic_Services
    [Arguments]    ${row}
    Open Excel Document    ${datatable}    TC18-EC
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window

Run Choice_Approvedproposal
    [Arguments]    ${row}
    ${ALLOW}=    Read Excel Cell    ${row}    8
    ${ALLOW}=    Evaluate    '' if $ALLOW in ['None', '', None] else $ALLOW.strip()
    Log To Console    Row ${row} - Allow: ${ALLOW}
    Run Keyword If    '${ALLOW}' == 'Y'
    ...    Run Keywords
    ...    Setup Speed
    ...    AND    Login As Lecturer
    ...    AND    Go To Approved Proposal    ${row}
    ...    AND    Fill Comment Form    ${row}
    ...    AND    Read Expected Result From Excel    ${row}
    ...    AND    Click Approved Button And Capture Alert    ${row}
    ...    AND    Read text from the screen and write it in Excel    ${row}
    ...    AND    Compare And Write Result To Excel   ${row}
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

Go To Approved Proposal
    [Arguments]    ${i}
    Click Element    //body/div[1]/div[1]/div[3]/a[1]
    Click Element    //tbody/tr[1]/td[9]/a[1]
    Sleep    3s

Fill Comment Form
    [Arguments]    ${i}
    ${PreApprovalComments}=    Read Excel Cell    ${i}    2
    ${PreApprovalComments}=    Evaluate    '' if $PreApprovalComments in ['None', '', None] else $PreApprovalComments
    Input Text    css:#commentDetail    ${PreApprovalComments}

Read Expected Result From Excel
    [Arguments]    ${i}
    ${ExpectedResult}=    Read Excel Cell    ${i}    4    
    Set Suite Variable    ${ExpectedResult}
    Log To Console    Expected Result: ${ExpectedResult}

Click Approved Button And Capture Alert
    [Arguments]    ${i}
    ${Action}=    Read Excel Cell    ${i}    3    
    Run Keyword If    '${Action}' == 'กดปุ่มอนุมัติแต่มีแก้ไข'    Run Keyword And Ignore Error    Click Element    //button[contains(text(),'อนุมัติแต่มีแก้ไข')]
    Run Keyword If    '${Action}' == 'กดปุ่มอนุมัติ'  Run Keyword And Ignore Error    Click Element    //button [@class='approve-button']
    Sleep    3s
    ${status}    ${message}=    Run Keyword And Ignore Error    Handle Alert    ACCEPT
    Run Keyword If    '${status}' == 'PASS'    Set Suite Variable    ${ActualMessage}    ${message}
    Run Keyword If    '${status}' != 'PASS'    Set Suite Variable    ${ActualMessage}    Alert Not Found
    Capture Page Screenshot    TC18_ApprovedProposal/Screenshots_ActionAlertMessage/${i}_ActionAlert.png

    Write Excel Cell    ${i}    6    ${ActualMessage}

Read text from the screen and write it in Excel
    [Arguments]    ${i}
    Wait Until Element Is Visible    xpath=//tbody/tr[1]/td[8]/span[1]    10s
    ${status}    ${ActualMessage}=    Run Keyword And Ignore Error    Get Text    xpath=//tbody/tr[1]/td[8]/span[1]
    Sleep    2
    Execute JavaScript    window.scrollTo(0, 300)
    Capture Page Screenshot    TC18_ApprovedProposal/Screenshots_Choice_ApprovedProposal/${i}_${ActualMessage}.png
    Capture Element Screenshot    xpath=//tbody/tr[1]/td[8]/span[1]    TC18_ApprovedProposal/Screenshots_Choice_ApprovedProposal/${i}_${ActualMessage}_Zoom.png
    write Excel Cell    ${i}    6    ${ActualMessage}
    Log To Console    Actual Message: ${ActualMessage}
    Set Suite Variable    ${ActualMessage}

Compare And Write Result To Excel
    [Arguments]    ${i}
    ${is_pass}=    Run Keyword And Return Status    Should Be Equal    ${ActualMessage}    ${ExpectedResult}
    Run Keyword If    ${is_pass}    Write Excel Cell    ${i}    7    Pass
    Run Keyword If    not ${is_pass}    Write Excel Cell    ${i}    7    Fail
    
    Write Suggestion Based On Comparison    ${i}    ${ExpectedResult}    ${ActualMessage}

Write Suggestion Based On Comparison
    [Arguments]    ${row}    ${ExpectedResult}    ${ActualMessage}
    ${ExpectedResult}=    Evaluate    '''${ExpectedResult}'''.strip()
    ${ActualMessage}=     Evaluate    '''${ActualMessage}'''.strip()
    ${is_match}=    Run Keyword And Return Status    Should Be Equal As Strings    ${ExpectedResult}    ${ActualMessage}
    Run Keyword If    ${is_match}
    ...    Write Excel Cell    ${row}    10    ข้อความแสดงผลถูกต้อง
    ...    ELSE
    ...    Write Excel Cell    ${row}    10    ข้อความไม่ตรงตามที่คาดหวังไว้ ควรแก้ไขเป็น ${ExpectedResult}


Go To Logout
    Click Element    //a[contains(text(),'ออกจากระบบ')]
    Sleep    1s



