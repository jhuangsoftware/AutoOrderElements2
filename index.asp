<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
	<meta http-equiv="expires" content="-1" />
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta name="copyright" content="2013, Web Site Management" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>AutoOrderElements 2.2</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<style type='text/css'>
		body
		{
			padding: 10px;
		}
	</style>
	<script type="text/javascript" src="js/jquery-1.8.3.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="Rqlconnector.js"></script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		
		$(document).ready(function() { 
			var ContentClassGuid = '<%= session("TreeGuid") %>';
			LoadElementsInContentClass(ContentClassGuid);
			LoadElementsInTemplate(ContentClassGuid);
		
			$('#reorder').click(function() { 
				ReorderElements(ContentClassGuid);
			});
			
			$('#reorderandclose').click(function() { 
				ReorderElements(ContentClassGuid);
				
				$(document).ajaxStop(function() {
					// close this window
					window.opener.ReloadTreeSegment();
					window.opener = '';
					self.close();
				});
			});
		}); 
		
		function LoadElementsInContentClass(ContentClassGuid)
		{
			var strRQLXML = '<PROJECT><TEMPLATE action="load" guid="' + ContentClassGuid + '"><ELEMENTS childnodesasattributes="0" action="load"/><TEMPLATEVARIANTS action="list"/></TEMPLATE></PROJECT>';
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				$('#all .content').empty();
				$(data).find('ELEMENT').each(function(){
					$('#all .content').append('<div id="' + $(this).attr('guid') + '">' + $(this).attr('eltname') + '</div>');
				});
			});
		}
		
		function LoadElementsInTemplate(ContentClassGuid)
		{
			var strRQLXML = '<PROJECT><TEMPLATE action="load" guid="' + ContentClassGuid + '"><TEMPLATEVARIANTS action="loadfirst"/></TEMPLATE></PROJECT>';
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
				$('#code .content').empty();
				TemplateRegexp = new RegExp('<' + '%([_\-a-zA-Z0-9]+?)%' + '>', 'ig');
				
				var Match = null;
				var TempItems = new Array();
				while(Match = TemplateRegexp.exec($(data).text()))
				{
					FoundItemIndex = FindInArray(TempItems, Match[1]);
					
					if(FoundItemIndex == -1)
					{
						var Element = new Object();
						Element.name = Match[1];
						TempItems.push(Element);
						
						$('#code .content').append('<div>' + Match[1] + '</div>');
					}
				}
			});
		}
	
		function ReorderElements(ContentClassGuid)
		{
			$('#processing').modal('show');
			
			// transfer divs in all into an array
			var TempItems = new Array();
			$('#all .content div').each(
			   function(){
			   		var Element = new Object();
			   		Element.name = $(this).text();
			   		Element.guid = $(this).attr('id');
					TempItems.push(Element);
			   }
			);

			var FoundItemIndex = -1;
			var ReorderedItems = new Array();
			// according to template order, find items in code
			$('#code .content div').each(
				function(i){
					FoundItemIndex = FindInArray(TempItems, $(this).text());
					
					if(FoundItemIndex != -1)
					{
						ReorderedItems.push(TempItems[FoundItemIndex]);
						TempItems.splice(FoundItemIndex, 1);
					}
			   }
			);
			
			// attached the left over items from TempItems to the end of ReorderedItems
			ReorderedItems = ReorderedItems.concat(TempItems);

			ExecuteReorderElementRql(ReorderedItems, ContentClassGuid);
		}
		
		function ExecuteReorderElementRql(ElementArray, ContentClassGuid)
		{
			// covert ElementArray into partial RQL XML format
			var strRQLInnerXML = '';
			for(var i = 0; i < ElementArray.length; i++)
			{
				strRQLInnerXML += '<ELEMENT guid="' + ElementArray[i].guid + '" />';
			}
			
			var strRQLXML = '<PROJECT><TEMPLATE guid="' + ContentClassGuid + '"><ELEMENTS action="sort">' + strRQLInnerXML + '</ELEMENTS></TEMPLATE></PROJECT>';
			RqlConnectorObj.SendRql(strRQLXML, false, function(data){
			
				$('#processing').modal('hide');
				location.reload();
			});
		}
				
		function FindInArray(SourceArray, SearchText)
		{
			var SearchPattern = new RegExp(SearchText,'gi');
			var CurrentArrayItemText;
			for(var i = 0; i < SourceArray.length; i++)
			{
				CurrentArrayItemText = SourceArray[i].name;
				if(CurrentArrayItemText.length == SearchText.length)
				{
					if(CurrentArrayItemText.match(SearchPattern))
					{
						return i;
					}
				}
			}
			
			return -1;
		}
	</script>
</head>
<body>
    <div class="alert alert-block alert-info">
		<h4>Auto Order Elements</h4>
		Reorder all elements according to order of appearance in code
    </div>
	<table class="table">
		<tr>
			<th>All Elements</th>
			<th>Order of Elements in Code</th>
		</tr>
		<tr>
			<td>
				<div class="alert" id="all">
					<div class="content">
						Loading...
					</div>
				</div>
			</td>
			<td>
				<div class="alert alert-success" id="code">
					<div class="content">
						Loading...
					</div>
				</div>
			</td>
		</tr>
	</table>
	<div class="form-actions">
		<div class="pull-right">
			<button class="btn btn-danger" id="reorderandclose">Reorder and Close</button>
			<button class="btn btn-success" id="reorder">Reorder</button>
		</div>
	</div>
	<div id="processing" class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
		<div class="modal-header">
			<h3 id="myModalLabel">Processing</h3>
		</div>
		<div class="modal-body">
			<p>Please wait...</p>
		</div>
	</div>
</body>
</html>