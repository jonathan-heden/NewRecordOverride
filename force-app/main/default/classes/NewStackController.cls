public class NewStackController {

    @AuraEnabled
    public static String getRecordTypeName(Id recordTypeId) {
        RecordType rt = [
            SELECT Id, Name
            FROM RecordType
            WHERE Id = :recordTypeId
        ];
        return rt.Name;
    }
    
    @AuraEnabled
    public static List<String> getLayoutFieldNames(Id recordTypeId) {
        RecordType rt = [
            SELECT Id, SobjectType
            FROM RecordType
            WHERE Id = :recordTypeId
        ];
        String SobjectType = rt.SobjectType;
        
        List<String> fieldNames = new List<String>();
        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {SobjectType + '-Stack Layout Create'});
        Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
        for(Metadata.LayoutSection section : layoutMd.layoutSections) {
            for(Metadata.LayoutColumn column : section.layoutColumns) {
                if(column.layoutItems != null) {
                    for(Metadata.LayoutItem item : column.layoutItems) {
                        fieldNames.add(item.field);
                    }
                }
            }
        }
        return fieldNames;
    }
    
    @AuraEnabled
    public static List<FieldWrapper> getLayoutFields(Id recordTypeId) {
        RecordType rt = [
            SELECT Id, SobjectType
            FROM RecordType
            WHERE Id = :recordTypeId
        ];
        String SobjectType = rt.SobjectType;
        
        List<FieldWrapper> fieldWrappers = new List<FieldWrapper>();
        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {SobjectType + '-Stack Layout Create'});
        Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
        for(Metadata.LayoutSection section : layoutMd.layoutSections) {
            for(Metadata.LayoutColumn column : section.layoutColumns) {
                if(column.layoutItems != null) {
                    for(Metadata.LayoutItem item : column.layoutItems) {
                        if(item.behavior == Metadata.UiBehavior.Readonly) {
                            continue;
                        }
                        String fieldName = item.field;
                        Boolean isRequired = (item.behavior == Metadata.UiBehavior.Required);
                        FieldWrapper fw = new FieldWrapper(fieldName, isRequired);
                        fieldWrappers.add(fw);
                    }
                }
            }
        }
        return fieldWrappers;
    }
    
    public class FieldWrapper {
        @AuraEnabled public String fieldName {get;set;}
        @AuraEnabled public Boolean isRequired {get;set;}
        
        public FieldWrapper(String fieldName, Boolean isRequired) {
            this.fieldName = fieldName;
            this.isRequired = isRequired;
        }
    }
}