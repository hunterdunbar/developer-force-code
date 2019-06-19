public virtual class Practices {
    public String name;
    public String technology;
    
    public Practices () { 
        
        this.name = 'Cervello';
        this.technology = 'Data';
        
    }
    
    public virtual String addEmployee(String name){
        return name;
    }
}