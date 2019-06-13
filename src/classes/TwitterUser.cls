public class TwitterUser {

    public String Id { get; set; }
    public String name { get; set; }
    
    // backward compatible
    public String screenName { get { return screen_name; } set { screen_name = value; } }
    public String screen_name { get; set; }
    
    public String description { get; set; }
    public String location { get; set; }
    
    // backward compatible
    public String profileImageUrl { get { return profile_image_url; } set { profile_image_url = value; } }
    public String profile_image_url { get; set; }
    
    public String url { get; set; }
    
    // backward compatible
    public Boolean isProtected { get { return is_protected; } set { is_protected = value; } }
    public Boolean is_protected { get; set; }
    
    // backward compatible
    public Integer followersCount { get { return followers_count; } set { followers_count = value; } }
    public Integer followers_count { get; set; }
    
    public String profile_background_color { get; set; }
    public String profile_text_color { get; set; }
    public String profile_link_color { get; set; }
    public String profile_sidebar_fill_color { get; set; }
    public String profile_sidebar_border_color { get; set; } 
    public Integer friends_count { get; set; }
    public String created_at { get; set; }
    public Integer favourites_count { get; set; }
    public Integer utc_offset { get; set; }
    public String time_zone { get; set; }
    public String profile_background_image_url { get; set; }
    public Boolean profile_background_tile { get; set; }
    public Boolean following { get; set; }
    public Boolean notifications { get; set; }
    public Integer statuses_count { get; set; }
    public TwitterStatus status { get; set; }
    
    public TwitterUser() {}
    
}