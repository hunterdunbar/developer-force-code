public class TwitterMessage {
    public String id { get; set; }
    public String sender_id { get; set; }
    public String text { get; 
        set {
            text = enhanced(value);
        }
    }
    public String recipient_id { get; set; }
    public String created_at { get; set; }
    public String sender_screen_name { get; set; }
    public String recipient_screen_name { get; set; }
    public TwitterUser sender { get; set; }
    public TwitterUser recipient { get; set; }
    
    public TwitterMessage() {}
     
    public TwitterMessage(String text, String recipient) {
        this.text = text;
    }

    private String enhanced(String value) {
        // Trying to embedd an anchor tag where a url is found
        Integer urlStart = value.indexOf('http://');
        if (urlStart != -1) {
            Integer urlEnd = value.indexOf(' ', urlStart);
            if (urlEnd == -1) urlEnd = value.length() - 1;
            String newValue = value.subString(0, urlStart - 1) + '<a href="' + 
                value.subString(urlStart, urlEnd + 1) + '" target="_blank">' + value.subString(urlStart, urlEnd + 1) + 
                '</a>';
            if (urlEnd != value.length()     - 1) {
                newValue += value.subString(urlEnd, value.length() -1);
            }
            return newValue;
        } else {
            return value;
        }
        
    }
}