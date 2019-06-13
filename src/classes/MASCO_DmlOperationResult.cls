/**
 * Created by Ivan on 12.04.2018.
 */

public with sharing class MASCO_DmlOperationResult {
    
    public Boolean success {get; set;}
    public List<ErrorFieldItem> errorItems {get; set;}
    public List<ErrorItem> errors {get; set;}
    public sObject result {get; set;}

    /**
     * Class for storing error related to field
     */
    public class ErrorFieldItem
    {
        public String fieldName {get; set;}
        public String fieldLabel {get; set;}
        public String errorMessage {get; set;}

        public ErrorFieldItem() {}

        public ErrorFieldItem(String fieldName, String errorMessage) {
            this.fieldName = fieldName;
            this.errorMessage = errorMessage;
        }

        public ErrorFieldItem(String fieldName, String errorMessage, String fieldLabel) {
            this(fieldName, errorMessage);
            this.fieldLabel = fieldLabel;
        }
    }

    /**
     * Class for storing error
     */
    public class ErrorItem
    {
        public String message {get; set;}

        public ErrorItem() {}

        public ErrorItem(String message) {
            this.message = message;
        }
    }

    /**
     * Method add error
     */
    public void addError(String message) {
        if (errors == null) {
            errors = new List<ErrorItem>();
        }
        errors.add(new ErrorItem(message));
    }

    /**
     * Method adds error related to field
     */
    public void addErrorItem(String fieldName, String errorMessage, String fieldLabel) {
        if (errorItems == null) {
            errorItems = new List<ErrorFieldItem>();
        }
        errorItems.add(new ErrorFieldItem(fieldName, errorMessage, fieldLabel));
    }
}