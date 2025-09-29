/*
persistence.init(true);
persistence.marshallObjects();
*/

var persistence = {
	debugEnabled: false,
	debug: function(msg) {
		if(this.debugEnabled)
			log.info(msg);
	},
	init: function(debugEnabled) {
		log.info("init() debugEnabled: " + debugEnabled);
		this.debugEnabled = debugEnabled;
		this.debug("persistence initialized with debug set to: " + debugEnabled);
	},
	
	// This function will modify the indexedMap attribute from the SQLResult by
	// converting the temporary aliases used in query to the object path counterparts
	convertAliasToNestedAttribute: function(indexedMap) {
		var props = indexedMap.propertyNames;
		var _this = this;
		//for each(var prop in props) {
		props.forEach(function(prop) {
			_this.debug("convertAliasToNestedAttribute prop: " + prop);
			if(tw.local.persistenceObject.selectAliasMap && tw.local.persistenceObject.selectAliasMap.containsKey(prop)) {
				var aliasReplace = tw.local.persistenceObject.selectAliasMap.get(prop);
				_this.debug("convertAliasToNestedAttribute BEFORE aliasReplace: " + aliasReplace);
				// If this is a list - denoted by '[]' - change to the 0th element in the list
				if(aliasReplace.indexOf('[]') >= 0)
					aliasReplace = aliasReplace.replace(/\[\]/g,'[0]')
					
				_this.debug("convertAliasToNestedAttribute AFTER aliasReplace: " + aliasReplace);

				indexedMap.setPropertyValue(aliasReplace, indexedMap.getPropertyValue(prop));
				indexedMap.removeProperty(prop);
			}		
		});
		return indexedMap;
	},
	
	mergeArraysDeep: function(arr1, arr2, key, prefix) { 
		prefix = prefix || "";
		var _this = this;
		var unique = arr1.concat(arr2).reduce(function(hash, item) {
			var current = hash[item[key]];
			if(!current) {
				hash[item[key]] = item;
			} else {
				function iterate(obj, item, prefix) {
					prefix = prefix || "";
					Object.keys(obj).forEach(function(prop) { 
						_this.debug("processing prop: " + prop);
						if(Array.isArray(obj[prop])) {
							_this.debug("prop is array");
							var newPrefix;
							if(prefix != "")
								newPrefix = prefix + "." + prop + "[]";
							else
								newPrefix = prop + "[]";
							_this.debug("newPrefix: " + newPrefix);
							// Lookup the new key to use for this array
							var newKey = tw.local.persistenceObject.nestedObjectPrimaryKeyMap.get(newPrefix);
							_this.debug("newKey: " + newKey);
							obj[prop] = _this.mergeArraysDeep(obj[prop], item[prop], newKey, newPrefix);
						} else if (typeof obj[prop] === 'object' && !(obj[prop] instanceof Date)) {
							_this.debug("prop is obj");
							var newPrefix;
							if(prefix != "")
								newPrefix = prefix + "." + prop;
							else
								newPrefix = prop;
							_this.debug("prefix: " + prefix);
							iterate(obj[prop], item[prop], newPrefix);
						}
					})
				}
				// 20240308 [Bob Riaz]: Fixed this logic to ensure nested lists more than 1 deep are properly populated
				if(prefix) {
					iterate(current, item, prefix);
				} else {
					iterate(current, item);
				}
			}
			return hash;
		}, {});
		
		return Object.keys(unique).map(function(key) {
			return unique[key];
		});
	},
	marshallObjects: function() {
		// Initialize objects list to the correct type dynamically using eval()
		eval("tw.local.objects = new tw.object.listOf." + tw.local.persistenceObject.entityName + "();");

		// Loop over SQLResult rows, convert indexedMap "dot" notation to JS object, use lodash '_.set()' function to build nested objects, 
		// then use 'mergeArraysDeep()' to merge arrays with the same primary key and add new items to the lists when a new primary key is found
		if(tw.local.results && tw.local.results[0] && tw.local.results[0].rows && tw.local.results[0].rows.listLength > 0) {
			var finalList = [];
			for(var i=0; i<tw.local.results[0].rows.listLength; i++) {
				var indexedMap = this.convertAliasToNestedAttribute(tw.local.results[0].rows[i].indexedMap);
				var json = JSON.stringify(indexedMap);
				this.debug("json: " + json);
				var obj = JSON.parse(json);
				this.debug("obj: " + obj);
				this.debug("obj: " + JSON.stringify(obj));
				var results = {};
				// Loop over all properties and use lodash to handle the heavy lifting here
				for(var prop in obj) {
					this.debug("prop: " + prop);
					this.debug("obj[prop]: " + obj[prop]);
					var dataType = tw.local.persistenceObject.typeMap.get(prop.replace(/\[0\]/g,'[]'));
					this.debug("prop: [" + prop + "], dataType: [" + dataType + "], value: [" + JSON.stringify(obj[prop]) + "]");
					// DO NOT set empty properties as this will result in lists containing empty members
					if((obj[prop] != null && obj[prop] != "")) {
						// If DATE type, need to obtain value from original object since date can't be converted
						// from JSON format. Also, apply server timezone offset from UTC date stored in database
						if(dataType.toUpperCase() == "DATE" || dataType.toUpperCase() == "TIMESTAMP") {
							var date = indexedMap[prop].toNativeDate();
							var utcOffset = date.getTimezoneOffset();
							date.setMinutes(date.getMinutes() - utcOffset);
							_.set(results, prop, date);
						} else {
							_.set(results, prop, obj[prop]);
						}
					}

					// 20230906 [Don Williams]: Stephen Perez found that integers saved as 0 were coming back as null in the BAW objects. Also, 
					// the second condition above - obj[prop] != "" - evaluates to false for numeric data so this logic was added as an ELSE IF.
					// If the property's value is 0 and the property is an INTEGER or DECIMAL type, then set this to 0.
					else if((dataType.toUpperCase() == "INTEGER" || dataType.toUpperCase() == "DECIMAL") && obj[prop] == 0) {
						_.set(results, prop, obj[prop]);
					}
					// 20240318 [Don Williams]: Objects with a nested child object in the definition containing a Boolean attribute were being populated 
					// even if the nested object had no data because database NULLs were being forced to a FALSE value instead of being left as NULL.
					// If the property's value is false and the property is a BIT type, then set the attribute value to false
					else if(dataType.toUpperCase() == "BIT" && (obj[prop] != null && obj[prop] == false)) {
					//else if(dataType.toUpperCase() == "BIT" && (obj[prop] == null || obj[prop] == false)) {
						_.set(results, prop, false);
					}
					this.debug("prop-by-prop results: " + JSON.stringify(results));
				}
				this.debug("results: " + JSON.stringify(results));
				finalList = this.mergeArraysDeep(finalList, [results], tw.local.persistenceObject.primaryKeyAttributeName);
			}
		}
		if(finalList && finalList.length > 0) {
			for(var i=0; i<finalList.length; i++) {
				this.debug("finalList[i]: " + JSON.stringify(finalList[i]));
				tw.local.objects.insertIntoList(tw.local.objects.listLength, finalList[i]);
			}
		} 
	}
};
