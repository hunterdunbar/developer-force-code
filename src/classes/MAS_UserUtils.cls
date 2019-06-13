/**
 * Created by Ivan on 04.04.2018.
 */
public with sharing class MAS_UserUtils {

    public enum Level {Student, Advisor, MASCOM, Reader, None}

    private static Contact currentContact = null;
    private static User currentUser = null;
    private static Profile currentProfile = null;
    private static Level currentLevel = null;
    private static Boolean isExistBoolean = null;

    //Advisor
    //Trenton Eveline
    //005f100000Haz0Y
    //Student
    //Alex
    //005f100000Haz3N
    //contactid 003f1000020qH2L
    //private static String selectedUser = '005f100000Haz3N';
    private static String selectedUser = UserInfo.getUserId();

    //private static final String studentProfileName = 'Student Community Login User';
    private static final String studentProfileName = 'Student Community Plus Login';
    private static final String advisorProfileName = 'Faculty Community User';
    private static final String readerProfileName = 'Reader Community User';
    private static final String mascomProfileName =  'MASCOM Community User';

    //This method for only in debug use
    public static void setUser(String userId) {
        selectedUser = userId;
    }

    public static User currentUser() {
        if(currentUser == null) {
            List<User> usersList = [SELECT Name, Contact.Id, Profile.Name FROM User WHERE Id = :selectedUser LIMIT 1];
            currentUser = (usersList.size() == 1) ? usersList.get(0) : null;
        }
        return currentUser;
    }

    public static Level getLevel() {
        if(currentLevel == null) {
            String profileName = currentUser().Profile.Name;
            if (profileName.equals(studentProfileName)) {
                currentLevel = Level.Student;
            } else if (profileName.equals(advisorProfileName)) {
                currentLevel = Level.Advisor;
            } else if (profileName.equals(mascomProfileName)) {
                currentLevel = Level.MASCOM;
            } else if (profileName.equals(readerProfileName)) {
                currentLevel = Level.Reader;
            } else {
                currentLevel = Level.None;
            }
        }
        return currentLevel;
    }

    @AuraEnabled
    public static String getUserRole() {
        return JSON.serialize(getLevel().name());
    }

    @AuraEnabled
    public static String getContactName(String contactId) {
        List<Contact> contacts = [SELECT Id, Name FROM Contact WHERE Id = :contactId];
        if(contacts.size() == 1) {
            return contacts.get(0).Name;
        }
        return null;
    }

}