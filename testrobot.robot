*** Setting ***
Documentation     Transferer les donnees dans une bd puis un fichier excel
Suite Setup       Connect To Database     psycopg2   ${dbname}   ${dbusername}   ${dbpassword}   ${dbhost}   ${dbport}
Suite Teardown    Disconnect From Database
Library           ExcelLibrary
Library           DatabaseLibrary


*** Variables ***

${chemin}       ${CURDIR}${/}\\donneecaisse.xlsx
${filename}     Feuil1
${resultDB}

${dbname}       dbtestrobot
${dbusername}   postgres
${dbpassword}   root
${dbhost}       localhost
${dbport}       5432
${tblname}      tbl_rapport_journalier

*** Test Cases ***
Lecture Fichier Excel
    Lire Excel    ${chemin}     ${filename}      2   3
    Lire Excel    ${chemin}     ${filename}      3   3
    Lire Excel    ${chemin}     ${filename}      4   3
    Lire Excel    ${chemin}     ${filename}      5   5
    Lire Excel    ${chemin}     ${filename}      11   4
    Lire Excel    ${chemin}     ${filename}      12   4
    Lire Excel    ${chemin}     ${filename}      13   4

    #Montant        encaisser par type d'encaissement
    Lire Excel    ${chemin}     ${filename}      15   4
    Lire Excel    ${chemin}     ${filename}      16   4

    ${Insertion}    Query       insert into tbl_rapport_journalier(nom_magasin,nom_responsable,email_responsable,jounee,carte_bancaire,especes,ticket_restaurant,prelevement,apportmonnaie) values('SOCOSE','KONATE DISTRIBUTION','konatetekernel@gmail.com','2014/06/12',2300,4500,6500,76323,700);

    ${select}       Query       select ((carte_bancaire + especes + ticket_restaurant)-(prelevement + apportmonnaie)) as diference from tbl_rapport_journalier
    Log             ${select}
*** Keywords ***

Lire Excel
    [Arguments]     ${NomChemin}       ${NomFichier}     ${Ligne}     ${Colonne}
    Open Excel Document     ${NomChemin}    1
    Get Sheet               ${NomFichier}           
    ${result}               Read Excel Cell       ${Ligne}        ${Colonne} 
    [Return]                ${result} 
    Close Current Excel Document