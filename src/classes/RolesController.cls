public class RolesController {
    public static List<ObjectWrapper> listObjectWrappers {get; set;}
    public static List<ObjectWrapper> listObjectWrappersIndexed {get; set;}
    public static Map<String, UserRole> mapIdName {get; set;}
    
    @AuraEnabled
    public static List<ObjectWrapper> getAllRoles() {
        
        mapIdName = new Map<String, UserRole>();
        List<UserRole> userRoles = [SELECT Name, DeveloperName, ParentRoleId FROM UserRole];
        listObjectWrappers = new List<ObjectWrapper>();
        
        if(userRoles != null) {
            Map<Id, ObjectWrapper> nodes = new Map<Id, ObjectWrapper>();
            Set<String> mainParents = new Set<String>();
            
            for(UserRole usrRole : userRoles){
                if(String.isBlank(usrRole.ParentRoleId)) {
                    mainParents.add(usrRole.Id);
                }
                mapIdName.put(usrRole.Id, usrRole);
            }
            
            Map<String, List<String>> mapParentChilds = new Map<String, List<String>>();
            
            for(UserRole role : userRoles) {
                if(role.ParentRoleId != null) {
                    if(mapParentChilds.containsKey(role.ParentRoleId))
                        mapParentChilds.get(role.ParentRoleId).add(role.Id);
                    else
                        mapParentChilds.put(role.ParentRoleId, new List<String>{role.Id});
                }
                else {
                    if(!mapParentChilds.containsKey(role.Id))
                        mapParentChilds.put(role.Id, new List<String>());
                }
            }
            
            for(String parentId : mapParentChilds.keySet()) {
                if(mainParents.contains(parentId)){
                    ObjectWrapper wrapper = new ObjectWrapper();
                    wrapper.roleId = parentId;
                    wrapper.name = mapIdName.get(parentId).Name;
                    wrapper.listOfChilds = new List<ObjectWrapper>();
                    getChilds(mapParentChilds, parentId, wrapper, parentId);
                    listObjectWrappers.add(wrapper);
                }
            }
        }
        indexListOfResults(listObjectWrappers);
        System.debug(JSON.serialize(listObjectWrappers));
        return listObjectWrappersIndexed;
    }
    
    @AuraEnabled
    public static void getChilds(Map<String, List<String>> mapParentChilds, String parentId, ObjectWrapper mainWrapper, String mainParentId) {
        List<String> childs =  mapParentChilds.get(parentId);
        
        if(childs != null) {
            for(String child : childs){
                ObjectWrapper wrapper = new ObjectWrapper();
                wrapper.roleId = child;
                wrapper.parentId = parentId;
                wrapper.name = mapIdName.get(child).Name;
                wrapper.mainParentId = mainParentId;
                wrapper.parentRoleId = mapIdName.get(child).ParentRoleId;
                wrapper.developerName = mapIdName.get(child).DeveloperName;
                wrapper.listOfChilds = new List<ObjectWrapper>();
                mainWrapper.listOfChilds.add(wrapper);
                getChilds(mapParentChilds, child, wrapper, wrapper.mainParentId);
            }
        }
    }
    
    @AuraEnabled
    public static void indexListOfResults(List<ObjectWrapper> listObjectWrappers) {
        if(listObjectWrappersIndexed == null)
            listObjectWrappersIndexed = new List<ObjectWrapper>();
        
        for(ObjectWrapper wrapper : listObjectWrappers){
            listObjectWrappersIndexed.add(wrapper);
            if(wrapper.listOfChilds.size() > 0)
                indexListOfResults(wrapper.listOfChilds);
        }
    }
    
   
    public class ObjectWrapper {
        
        @AuraEnabled public String roleId {get; set;}
        @AuraEnabled public String name {get; set;}
        @AuraEnabled public String parentId {get; set;}
        @AuraEnabled public String mainParentId {get; set;}
        @AuraEnabled public String parentRoleId {get; set;}
        @AuraEnabled public String developerName {get; set;}
        
        @AuraEnabled public List<ObjectWrapper> listOfChilds {get; set;}
    }
}