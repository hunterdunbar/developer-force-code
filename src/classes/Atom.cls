public virtual class Atom {

    public static void testThis() {
        TwitterForce tf = new TwitterForce();
        Atom a = new Atom();
        System.debug(LoggingLevel.WARN, tf.wordSearch('Cloudforce'));
    }
    
    private String tString;
        
    public void trace(String t)  { 
        if (tString == null) 
                tString = '';
        tString += t + '\n';
    }
    
    public void printTrace() {
        //System.debug(LoggingLevel.INFO, tString);
    }
    
    public virtual XmlStreamReader getReader(String xml) {
        // TODO
        /* This is to avoid a bug in XmlStreamReader - 
         * it can't handle extended characters
        */
        xml = xml.replaceAll('&#246;', 'o');    
        xml = xml.replaceAll('&#248;', 'o');
        xml = xml.replaceAll('&#8220;', '"');
        xml = xml.replaceAll('&#8221;', '"');
        xml = xml.replaceAll('&#[^;]*;', '');
        
        XmlStreamReader r = new XmlStreamReader(xml);
        r.setCoalescing(true);
        r.next(); 
        return r;
    }
    
// -------------------------------------------------------
// Parsing methods  
// -------------------------------------------------------

    public virtual Feed parseFeed(XmlStreamReader r) {
        Feed f = null;
        tString = '';
        trace('Starting Feed Parse');
        if (r.getLocalName().equals('feed')) {
            trace('Found feed tag: ' + r.getLocalName() + ' event:' + r.getEventType());
            f = new Feed();
            String currentNode;
            String currentPrefix;
            Map<String, String> atts;
            while (r.hasNext()  ) {
                if (r.getEventType().name().equals('START_ELEMENT')) {
                    trace('FSTART: ' + r.getLocalName());
                    atts = new Map<String, String>();
                    if (r.getAttributeCount() > 0) {
                        for (Integer i=0;i<r.getAttributeCount(); i++) {
                            atts.put(r.getAttributeLocalName(i), r.getAttributeValueAt(i));
                        }
                    }
                    currentPrefix = r.getPrefix();
                    currentNode = r.getLocalName();
                    if (currentNode.equals('author')) {
                        f.author.add(parsePerson(r));
                        r.next();
                    } else if (currentNode.equals('category')) {
                        f.category = parseCategory(r);
                    } else if (currentNode.equals('contributor')) {
                        f.contributor.add(parsePerson(r));
                        r.next();
                    } else if (currentNode.equals('link')) {
                        trace('Create link item...');
                        f.link.add(parseLink(r));
                        r.next();
                    } else if (currentNode.equals('entry')) {
                        trace('Create entry item...');
                        f.entry.add(parseEntry(r));
                        r.next();
                    }  
                    handleComplexElementExtension(f, r, atts);
                } else if (r.getEventType().name().equals('END_ELEMENT')) {
                    trace('END: ' + r.getLocalName());
                } else if (r.getEventType().name().equals('CHARACTERS')) {
                    if (r.getText().trim().length() > 0) {
                        if (currentNode.equals('id')) {
                            f.id = r.getText();
                        } else if (currentNode.equals('title')) {
                            f.title = new Text();
                            f.title.text = r.getText();
                            if (atts.size() > 0) 
                                f.title.typez = atts.get('type');
                            else 
                                f.title.typez = 'text';
                        } else if (currentNode.equals('updated')) {
                            f.updated = DateTime.valueOf(r.getText().replace('T', ' '));
                        }  else if (currentNode.equals('rights')) {
                            f.rights = new Text();
                            f.rights.text = r.getText();
                            f.rights.typez = atts.get('type');
                        } else if (currentNode.equals('subtitle')) {
                            f.subtitle = new Text();
                            f.subtitle.text = r.getText();
                            f.subtitle.typez = atts.get('type');
                        } else if (currentNode.equals('logo')) {
                            f.logo = r.getText();
                        } else if (currentNode.equals('icon')) {
                            f.icon = r.getText();
                        } else if (currentNode.equals('itemsPerPage')) {
                            f.itemsPerPage = Integer.valueOf(r.getText());
                        }
                        handleSimpleElementExtension(f, r, atts);
                        trace(r.getEventType().name() + ' for node ' + currentNode + ': ' + r.getText());
                    }
                }
                r.next();
            }
        }
        printTrace();
        return f;
    }
    
    public virtual void handleComplexElementExtension(Feed f, XmlStreamReader r, Map<String, String> atts) {
        // If you are overriding this to handle extensions, make sure you
        // include r.next() and continue; as the last two lines of code.
    }
    
    public virtual void handleSimpleElementExtension(Feed f, XmlStreamReader r, Map<String, String> atts) {
        
    }
    
    public virtual Category parseCategory(XmlStreamReader r) {
        Category c = new Category();
        for (Integer i=0;i<r.getAttributeCount();i++) {
            String attName = r.getAttributeLocalName(i);
            String val = r.getAttributeValueAt(i);
            if (attName.equals('term')) {
                c.term = val;
            } else if (attName.equals('scheme')) {
                c.scheme = val;
            } else if (attName.equals('label')) {
                c.label = val;
            }
        }
        return c;
    }
    
    public virtual Link parseLink(XmlStreamReader r) {
        Link l = new Link();
        for (Integer i=0;i<r.getAttributeCount(); i++) {
            String attName = r.getAttributeLocalName(i);
            String val = r.getAttributeValueAt(i);
            trace('LINK Parse - attribute: ' + attname + ' = ' + val);
            if (attName.equals('href')) 
                l.href = val;
            else if (attName.equals('rel')) 
                l.rel = val;
            else if (attName.equals('type')) 
                l.typez = val;
            else if (attName.equals('hreflang')) 
                l.hreflang = val;
            else if (attName.equals('title')) {
                l.title.text = val;
                l.title.typez = 'text';
            } else if (attName.equals('length')) { 
                l.length.text = val;
                l.length.typez = 'text';
            }
        }
        return l;
    }

    public virtual Person parsePerson(XmlStreamReader r) {
        Person p = null;
        if (r.getLocalName().equals('author') || 
                r.getLocalName().equals('contributor')){
            
            p = new Person();
            while (true) {
                r.nextTag();
                String pTag = r.getLocalName();
                trace('parsePerson:::' + pTag);
                if (r.getLocalName().equals('author')|| 
                        r.getLocalName().equals('contributor')) {
                    break;
                } 
                r.next();
                
                if (!r.hasText()) 
                    continue;
                String c = r.getText();
                r.next();
                String n = r.getLocalName();
                if (n.equals('name'))
                    p.name = c;
                else if (n.equals('uri')) 
                    p.uri = c; 
                else if (n.equals('email')) 
                    p.email = c;
            }
        }       
        return p;
    }
    
    public Entry parseEntry(XmlStreamReader r) {
        Entry e = null;
        trace('Starting entry Parse');
        if (r.getLocalName().equals('entry')) {
            trace('Found feed tag: ' + r.getLocalName() + ' event:' + r.getEventType());
            e = new Entry();
            String currentNode;
            String currentPrefix;
            Content content;
            while (r.hasNext()  ) {
                
                //r.next();
                if (r.getEventType().name().equals('START_ELEMENT')) {
                    trace('START: ' + r.getLocalName());
                    currentNode = r.getLocalName();
                    currentPrefix = r.getPrefix();
                    if (currentNode.equals('link')) {
                        trace('Create link item...');
                        e.link.add(parseLink(r));
                        r.next();
                    } else if (currentNode.equals('content')) {
                        content = new Content();
                        content.typez = r.getAttributeValue('', 'type');
                        content.src = r.getAttributeValue('', 'src');
                    } else if (currentNode.equals('author')) {
                        e.author.add(parsePerson(r));
                        r.next();
                    }
                } else if (r.getEventType().name().equals('END_ELEMENT')) {
                    trace('END: ' + r.getLocalName());
                    if (r.getLocalName().equals('entry')) {
                        return e;
                    }
                } else if (r.getEventType().name().equals('CHARACTERS')) {
                    if (r.getText().trim().length() > 0) {
                        if (currentNode.equals('id')) {
                            e.id = r.getText();
                        } else if (currentNode.equals('title')) {
                            e.title = new Text();
                            e.title.text = r.getText();
                            e.title.typez = 'text';
                        } else if (currentNode.equals('updated')) {
                            e.updated = DateTime.valueOf(r.getText().replace('T', ' '));
                        } else if (currentNode.equals('published')) {
                            e.published = DateTime.valueOf(r.getText().replace('T', ' '));
                        } else if (currentNode.equals('content')) {
                            content.textContent = r.getText();
                            e.content = content;
                        } else if (currentNode.equals('source') && currentPrefix.equals('twitter')) {
                            // Twitter source
                            e.twitterSource = r.getText();
                        }
                        trace(r.getEventType().name() + ' for node ' + currentNode + ': ' + r.getText());
                    }
                }
                r.next();
            }
        }
        printTrace();
        return e;
    }
    
// -------------------------------------------------------
// End Parsing methods  
// -------------------------------------------------------
    
    public virtual class Feed {
        public List<Person> author { get; set; }
        public Category category { get; set; }
        public List<Person> contributor { get; set; }
        public String icon { get; set; }
        public String id { get; set; }
        public List<Link> link { get; set; }
        public String logo { get; set; }
        public Text rights { get; set; }
        public Text subtitle { get; set; }
        public Text title { get; set; }
        public Datetime updated { get; set; }
        public List<Entry> entry { get; set; }
        public Integer itemsPerPage { get; set; }
        
        public String htmlLink {
            get {
                return '';
            }
        }
        public Feed() {
            author = new List<Person>();
            contributor = new List<Person>();
            link = new List<Link>();
            entry = new List<Entry>();
        }
        
        public virtual void testProperties() {
            String hl = htmlLink;
            author = null;
            if (author == null) author = new List<Person>();
            new Person().testProperties();
            if (category == null) new Category().testProperties();
            contributor = null;
            if (contributor == null) contributor = new List<Person>();
            if (icon == null) icon = 'foo';             
            if (id == null) id = 'foo';
            link = null;
            if (link == null) link = new List<Link>();
            new Link().testProperties();
            if (logo == null) logo = 'foo';
            if (rights == null) rights = new Text();
            rights.testProperties();
            if (subtitle == null) subtitle = new Text();
            if (title == null) title = new Text();
            if (updated == null) updated = Datetime.now();
            entry = null;
            if (entry == null) entry = new List<Entry>();
            entry = new List<Entry>();
            new Entry().testProperties();
            if (itemsPerPage == null) itemsPerPage = 0;
            new Generator().testProperties();
        }
    }   
    
    public virtual class Entry extends Feed {
        public Content content { get; set; }
        public Datetime published { get; set; }
        public Feed source { get; set; }
        public Text summary { get; set; }
        public String twitterSource { get; set; }
        
        public override void testProperties() {
            if (content == null) content = new Content();
            new Content().testProperties();
            if (published == null) published = Datetime.now();
            if (source == null) source = new Feed();
            if (summary ==  null) summary = new Text();
            if (twitterSource == null) twitterSource = 'foo';
        }
    }
    
    public class Content {
        public String typez { get; set; }
        public String textContent { get; set; }
        public String src { get; set; }
        
        public void testProperties() {
            if (typez == null) typez = 'foo';
            if (textContent == null) textContent = 'foo';
            if (src == null) src = 'foo';
        }
    }
    
    public virtual class Text {
        public string typez { get; set; }
        public String text { get; set; }
        
        public void testProperties() {
            if (typez == null) typez = 'foo';
            if (text == null) text = 'foo';
        }
    }
    public virtual class Link {
        public String href { get; set; }
        public String rel { get; set; }
        public String typez { get; set; }
        public String hreflang { get; set; }
        public Text title { get; set; }
        public Text length { get; set; }
        
        public void testProperties() {
            if (href == null) href = 'foo';
            if (rel == null) rel = 'foo';
            if (typez == null) typez = 'foo';
            if (hreflang == null) hreflang = 'foo';
            if (title == null) title = new Text();
            if (length == null) length = new Text();
        }
    }
    
    public virtual class Generator {
        public String uri { get; set; }
        public String version { get; set; }
        
        public void testProperties() {
            if (uri == null) uri = 'foo';
            if (version == null) version = 'foo';
        }
    }
    
    public virtual class Person {
        public String name { get; set; }
        public String uri { get; set; }
        public String email { get; set; }
        
        public void testProperties() {
            if (name == null) name = 'foo';
            if (uri == null) uri = 'foo';
            if (email == null) email = 'foo';
        }
    }
    
    public virtual class Category { 
        public String term { get; set; }
        public String scheme { get; set; }
        public String label { get; set; }
        
        public void testProperties() {
            if (term == null) term = 'foo';
            if (scheme == null) scheme = 'foo';
            if (label == null) label = 'foo';
        }
        
    }

}