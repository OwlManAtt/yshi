namespace :eve do
  desc "Pulls static data (BPs, materials, etc) from the EVE database dump."
  task :import_static => :environment do

    # This task requires the eve_dump database be loaded with the EVE database extract.
    # The MySQL version of this extract was provided by ``Jercy Fravowitz''. It was
    # located at <http://eve.no-ip.de/apo15/>. CCP releases the extract in a format only
    # MS SQL can understand.

    # Truncate the static data tables...
    %w[item_groups blueprints blueprint_materials blueprint_skills].each {|table|
      ActiveRecord::Base.connection.execute("TRUNCATE TABLE #{table}")
    }

    ["INSERT INTO item_groups 
      (id,group_name)
      SELECT 
        invGroups.groupID AS id, 
        invGroups.groupName AS group_name
      FROM eve_dump.invGroups 
      WHERE invGroups.published = 1 
      AND invGroups.categoryID = 9",
      
      "INSERT INTO blueprints 
      (id,blueprint_name,item_group_id,product_item_id,product_name,product_batch_quantity,base_price,tech_level,production_limit)
      SELECT
        invTypes.typeID AS id,
        invTypes.typeName AS blueprint_name,
        invTypes.groupID AS group_id,
        invTypeProduct.typeID AS product_item_id,
        invTypeProduct.typeName AS product_name,
        invTypeProduct.portionSize AS product_quantity,
        invTypes.basePrice AS blueprint_base_price,
        invBlueprintTypes.techLevel AS product_tech_level,
        invBlueprintTypes.maxProductionLimit AS production_limit
      FROM eve_dump.invTypes
      INNER JOIN eve_dump.invBlueprintTypes ON invTypes.typeID = invBlueprintTypes.blueprintTypeID
      INNER JOIN eve_dump.invTypes AS invTypeProduct ON invBlueprintTypes.productTypeId = invTypeProduct.typeID
      WHERE invTypes.published = 1",

      "INSERT INTO blueprint_materials
      (material_type_id,blueprint_id,material_name,quantity,damage_per_job,material_type)
      SELECT 
        invTypes.typeID AS material_type_id,
        typeActivityMaterials.typeID AS blueprint_type_id,
        invTypes.typeName AS material_name,
        IF(invTypes.groupID = 332, typeActivityMaterials.quantity, round(typeActivityMaterials.quantity * (1 + invBlueprintTypes.wasteFactor / 100) ) ) AS quantity, 
        typeActivityMaterials.damagePerJob AS damage_per_job,
        'raw' AS meterial_type
      FROM eve_dump.typeActivityMaterials
      INNER JOIN eve_dump.invTypes ON typeActivityMaterials.requiredtypeID = invTypes.typeID
      INNER JOIN eve_dump.invGroups ON invTypes.groupID = invGroups.groupID
      INNER JOIN eve_dump.invBlueprintTypes ON typeActivityMaterials.typeID = invBlueprintTypes.blueprintTypeID
      WHERE typeActivityMaterials.activityId = 1 -- Manufacturing
      AND invGroups.categoryID NOT IN (7,16) -- Modules, skills
      AND typeActivityMaterials.quantity > 0
      AND invTypes.published = 1",

      "INSERT INTO blueprint_materials
      (material_type_id,blueprint_id,material_name,quantity,damage_per_job,material_type)
      SELECT
        invTypes.typeID AS material_type_id,
        typeActivityMaterials.typeID AS blueprint_type_id,
        invTypes.typeName AS material_name, 
        typeActivityMaterials.quantity AS quantity, 
        typeActivityMaterials.damagePerJob AS damage_per_job,
        'component' AS material_type 
      FROM eve_dump.typeActivityMaterials
      INNER JOIN eve_dump.invTypes ON typeActivityMaterials.requiredtypeID = invTypes.typeID
      INNER JOIN eve_dump.invGroups ON invTypes.groupID = invGroups.groupID
      WHERE typeActivityMaterials.activityId = 1 -- Manufacturing
      AND invGroups.categoryID IN (6,7) -- Ships, modules
      AND invTypes.published = 1",

      "INSERT INTO blueprint_skills
      (skill_type_id,blueprint_id,skill_name,level)
      SELECT
        invTypes.typeID AS skill_type_id,
        typeActivityMaterials.typeID AS blueprint_type_id,  
        invTypes.typeName AS skill_name, 
        typeActivityMaterials.quantity AS level
      FROM eve_dump.typeActivityMaterials
      INNER JOIN eve_dump.invTypes ON typeActivityMaterials.requiredtypeID = invTypes.typeID
      INNER JOIN eve_dump.invGroups ON invTypes.groupID = invGroups.groupID
      WHERE typeActivityMaterials.activityId = 1 
      AND invGroups.categoryID = 16
      AND invTypes.published = 1"
    ].each {|query|
      ActiveRecord::Base.connection.execute(query)
    }
  end # import
end # eve
