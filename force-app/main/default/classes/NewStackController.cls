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
    public static List<String> getLayoutFieldNames() {
        List<String> fieldNames = new List<String>();
        List<Metadata.Metadata> layouts = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String> {'Stack__c-Stack Layout Create'});
        Metadata.Layout layoutMd = (Metadata.Layout)layouts.get(0);
        for(Metadata.LayoutSection section : layoutMd.layoutSections) {
            for (Metadata.LayoutColumn column : section.layoutColumns) {
                if (column.layoutItems != null) {
                    for (Metadata.LayoutItem item : column.layoutItems) {
                        fieldNames.add(item.field);
                    }
                }
            }
        }
        return fieldNames;
    }
}