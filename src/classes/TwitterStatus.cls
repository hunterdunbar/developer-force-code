public class TwitterStatus {

    public DateTime created { get; set; }
    // backward compatibility
    public String createdAt { get { return created_at; } set { created_at = value; } }
    public String created_at { get; 
        set {
            created_at = value;
            String[] parts = value.split(' ');
            String mon = getMonthVal(parts[1]);
            String day = parts[2];
            String timeval = parts[3];
            String offset = parts[4];
            String year = parts[5];
            String[] timeParts = timeval.split(':');
            created = dateTime.newInstance(
                Integer.valueOf(year), 
                Integer.valueOf(mon), 
                Integer.valueOf(day),
                Integer.valueOf(timeParts[0]) - 7, 
                Integer.valueOf(timeParts[1]),
                Integer.valueOf(timeParts[2]));
            getTimeStamp();
        }
    }
    public String timeStamp { get; set; }
    public String Id { get; set; } 
    public String text { get; 
        set {
            text = enhanced(value); 
        }
    }
    public String source { get; set; }
    public Boolean truncated { get; set; }
    
    // backward compatibility
    public String inReplyToStatusId { get { return in_reply_to_status_id; } set { in_reply_to_status_id = value; } }
    public String in_reply_to_status_id { get; set; }
    
    // backward compatibility
    public String inReplyToUserId { get { return in_reply_to_user_id; } set { in_reply_to_user_id = value; } }
    public String in_reply_to_user_id { get; set; }
    public Boolean favorited { get; set; }
    public TwitterUser user { get; set; }
    
    public TwitterStatus() {}
    
    private String enhanced(String value) {
        // Trying to embedd an anchor tag where a url is found
        Integer urlStart = value.indexOf('http://');
        if (urlStart != -1) {
            Integer urlEnd = value.indexOf(' ', urlStart);
            if (urlEnd == -1) urlEnd = value.length() - 1;
            if (urlStart > 0) urlStart -= 1;
            String newValue = value.subString(0, urlStart + 1) + '<a href="' + 
                value.subString(urlStart, urlEnd + 1).trim() + '" target="_blank">' + value.subString(urlStart, urlEnd + 1).trim() + 
                '</a>';
            if (urlEnd != value.length()     - 1) {
                newValue += value.subString(urlEnd, value.length());
            }
            return newValue;
        } else {
            return value;
        }
        
    }
    public void testGetMonthVal() {
        System.assertEquals('1', getMonthVal('JAN'));
        System.assertEquals('2', getMonthVal('FEB'));
        System.assertEquals('3', getMonthVal('MAR'));
        System.assertEquals('4', getMonthVal('APR'));
        System.assertEquals('5', getMonthVal('MAY'));
        System.assertEquals('6', getMonthVal('JUN'));
        System.assertEquals('7', getMonthVal('JUL'));
        System.assertEquals('8', getMonthVal('AUG'));
        System.assertEquals('9', getMonthVal('SEP'));
        System.assertEquals('10', getMonthVal('OCT'));
        System.assertEquals('11', getMonthVal('NOV'));
        System.assertEquals('12', getMonthVal('DEC'));
    }
    private String getMonthVal(String ma) {
        ma = ma.toLowerCase();
    
        if (ma == 'jan') 
            return '1';
        else if (ma == 'feb') 
            return '2';
        else if (ma == 'mar')
            return '3';
        else if (ma == 'apr')
            return '4';
        else if (ma == 'may')
            return '5';
        else if (ma == 'jun') 
            return '6';
        else if (ma == 'jul')
            return '7';
        else if (ma == 'aug')
            return '8';
        else if (ma == 'sep')
            return '9';
        else if (ma == 'oct')
            return '10';
        else if (ma == 'nov')
            return '11';
        else 
            return '12';
    }
    
    public void testGetTimeStamp() {
        created = dateTime.now().addSeconds(-30);
        getTimeStamp();
        created = dateTime.now().addSeconds(-90);
        getTimeStamp();
        created = dateTime.now().addHours(-1);
        getTimeStamp();
        created = dateTime.now().addDays(-2);
        getTimeStamp();
    }
    private void getTimeStamp() {
        System.debug('\n\nCalling into getTimeStamp()\n\n');
        
        DateTime dt = dateTime.now();
    
        Long nowMS = dateTime.now().getTime();
        Long tweetMS = created.getTime();
        Long elapsed = nowMS - tweetMS;
        Long elapsedSeconds = elapsed / 1000;
        Long elapsedMinutes = elapsedSeconds / 60;
        Long elapsedHours = elapsedMinutes / 60;
        
        if (elapsedSeconds < 60) {
            timeStamp = 'less than a minute ago ';
        } else if (elapsedMinutes < 60) {
            String m = 'minutes';
            if (elapsedMinutes < 2 ) {
                m = 'minute';
            }       
            timeStamp = 'about ' + elapsedMinutes + ' ' + m + ' ago ';
        } else if (elapsedHours < 24) {
            String h = 'hours'; 
            if (elapsedHours < 2) {
                h = 'hour';
            }
            timeStamp = 'about ' + elapsedHours + ' ' + h + ' ago ';
        } else {
            timeStamp = created.formatGmt('hh:mm a MMM dd');
        }
    }
}