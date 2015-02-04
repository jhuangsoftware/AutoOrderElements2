function AutoOrderElements(RqlConnectorObj, ContentClassGuid) {
	var ThisClass = this;
	this.RqlConnectorObj = RqlConnectorObj;
	this.ContentClassGuid = ContentClassGuid;
	
	this.TemplateContentClassElements = '#template-content-class-elements';
	this.TemplateContentClassTemplateElements = '#template-content-class-template-elements';
	this.TemplateProcessingDialog = '#processing';
	
	this.LoadElementsInContentClass(ContentClassGuid);
	this.LoadElementsInContentClassTemplate(ContentClassGuid);
	
	$('body').on('click', '#reorderandclose', function(){
		ThisClass.Reorder(ThisClass.ContentClassGuid, function(){
			window.opener.ReloadTreeSegment();
			window.opener = '';
			self.close();
		});
	});
	
	$('body').on('click', '#reorder', function(){
		ThisClass.Reorder(ThisClass.ContentClassGuid, function(){
			location.reload();
		});
	});
}

AutoOrderElements.prototype.LoadElementsInContentClass = function(ContentClassGuid) {
	var ThisClass = this;
	
	var RqlXml = '<PROJECT><TEMPLATE action="load" guid="' + ContentClassGuid + '"><ELEMENTS childnodesasattributes="0" action="load"/><TEMPLATEVARIANTS action="list"/></TEMPLATE></PROJECT>';
	this.RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var Elements = [];

		$(data).find('ELEMENT').each(function(){
			if($(this).attr('eltname')){
				var ElementObj = {
					guid: $(this).attr('guid'),
					name: $(this).attr('eltname')
				};
				
				Elements.push(ElementObj);
			}
		});
		

		ThisClass.UpdateArea(ThisClass.TemplateContentClassElements, {elements: Elements});
	});
}

AutoOrderElements.prototype.LoadElementsInContentClassTemplate = function(ContentClassGuid) {
	var ThisClass = this;
	
	var RqlXml = '<PROJECT><TEMPLATE action="load" guid="' + ContentClassGuid + '"><TEMPLATEVARIANTS action="loadfirst"/></TEMPLATE></PROJECT>';
	this.RqlConnectorObj.SendRql(RqlXml, false, function(data){
		var Elements = [];
		var ElementNames = [];
		var TemplateRegexp = new RegExp('<' + '%([_\-a-zA-Z0-9]+?)%' + '>', 'ig');
		var Match = null;
		
		while(Match = TemplateRegexp.exec($(data).text()))
		{
			ElementName = Match[1];
			
			if($.inArray(ElementName, ElementNames) == -1)
			{
				ElementNames.push(ElementName);
			
				var ElementObj = {
					name: ElementName
				};
				
				Elements.push(ElementObj);
			}
		}

		ThisClass.UpdateArea(ThisClass.TemplateContentClassTemplateElements, {elements: Elements});
	});
}


AutoOrderElements.prototype.Reorder = function(ContentClassGuid, CallbackFunc){
	var ThisClass = this;
	$(this.TemplateProcessingDialog).modal('show');

	var TemplateContentClassElementsContainer = $(this.TemplateContentClassElements).attr('data-container');
	var TemplateContentClassTemplateElementsContainer = $(this.TemplateContentClassTemplateElements).attr('data-container');
	var ContentClassElements = [];
	var ContentClassTemplateElements = [];
	var ReorderedContentClassElementGuids = [];

	$(TemplateContentClassTemplateElementsContainer).find('div').each(function(){
		var ContentClassTemplateElementName = $(this).text();
		
		var ContentClassElementGuid;
		
		$(TemplateContentClassElementsContainer).find('div[data-name=' + ContentClassTemplateElementName + ']').each(function(){
			ContentClassElementGuid = $(this).attr('data-guid');
			$(this).remove();
		});
		
		if(ContentClassElementGuid){
			ReorderedContentClassElementGuids.push(ContentClassElementGuid);
		}
	});
	
	$(TemplateContentClassElementsContainer).find('div').each(function(){
		ReorderedContentClassElementGuids.push($(this).attr('data-guid'));
		$(this).remove();
	});
	
	var RqlXmlInner = '';
	$.each(ReorderedContentClassElementGuids, function(){
		RqlXmlInner += '<ELEMENT guid="' + this + '" />';
	});

	var RqlXml = '<PROJECT><TEMPLATE guid="' + ContentClassGuid + '"><ELEMENTS action="sort">' + RqlXmlInner + '</ELEMENTS></TEMPLATE></PROJECT>';
	this.RqlConnectorObj.SendRql(RqlXml, false, function(data){
		$(ThisClass.TemplateProcessingDialog).modal('hide');
		CallbackFunc();
	});
}

AutoOrderElements.prototype.UpdateArea = function(TemplateId, Data){
	var ContainerId = $(TemplateId).attr('data-container');
	var TemplateAction = $(TemplateId).attr('data-action');
	var Template = Handlebars.compile($(TemplateId).html());
	var TemplateData = Template(Data);

	if((TemplateAction == 'append') || (TemplateAction == 'replace'))
	{
		if (TemplateAction == 'replace') {
			$(ContainerId).empty();
		}

		$(ContainerId).append(TemplateData);
	}

	if(TemplateAction == 'prepend')
	{
		$(ContainerId).prepend(TemplateData);
	}

	if(TemplateAction == 'after')
	{
		$(ContainerId).after(TemplateData);
	}
}