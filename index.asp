<!DOCTYPE html>
<html>
<head>
	<meta http-equiv="expires" content="-1" />
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<meta name="copyright" content="2013, Web Site Management" />
	<meta http-equiv="X-UA-Compatible" content="IE=edge" >
	<title>AutoOrderElements 2.2</title>
	<link rel="stylesheet" href="css/bootstrap.min.css" />
	<link rel="stylesheet" href="css/custom.css" />
	<script type="text/javascript" src="js/jquery-1.10.2.min.js"></script>
	<script type="text/javascript" src="js/bootstrap.min.js"></script>
	<script type="text/javascript" src="js/handlebars-v2.0.0.js"></script>
	<script type="text/javascript" src="js/auto-order-elements-2.js"></script>
	<script type="text/javascript" src="rqlconnector/Rqlconnector.js"></script>
	<script id="template-content-class-elements" type="text/x-handlebars-template" data-container="#all" data-action="replace">
		{{#each elements}}
		<div data-guid="{{guid}}" data-name="{{name}}"><i class="icon-remove"></i> {{name}}</div>
		{{/each}}
	</script>
	<script id="template-content-class-template-elements" type="text/x-handlebars-template" data-container="#code" data-action="replace">
		{{#each elements}}
		<div>{{name}}</div>
		{{/each}}
	</script>
	<script id="template-processing-modal" type="text/x-handlebars-template" data-container="#processing" data-action="replace">
		<div class="modal hide fade" data-backdrop="static" tabindex="-1" role="dialog" aria-labelledby="myModalLabel" aria-hidden="true">
			<div class="modal-header">
				<h3 id="myModalLabel">Processing</h3>
			</div>
			<div class="modal-body">
				<p>Please wait...</p>
			</div>
		</div>
	</script>
	<script id="template-delete-modal" type="text/x-handlebars-template" data-container="#delete-confirmation" data-action="replace">
		<div id="delete-confirmation" class="modal fade">
			<div class="modal-header">
				<button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
				<h3>Delete Element</h3>
			</div>
			<div class="modal-body">
				<div class="alert alert-danger" data-guid="{{guid}}">{{name}}</div>
			</div>
			<div class="modal-footer">
				<a href="#" class="btn" data-dismiss="modal" aria-hidden="true">Close</a>
				<a href="#" class="btn btn-danger delete" data-dismiss="modal" aria-hidden="true">Delete</a>
			</div>
		</div>
	</script>
	<script type="text/javascript">
		var LoginGuid = '<%= session("loginguid") %>';
		var SessionKey = '<%= session("sessionkey") %>';
		var ContentClassGuid = '<%= session("TreeGuid") %>';
		var RqlConnectorObj = new RqlConnector(LoginGuid, SessionKey);
		
		$(document).ready(function() { 
			var AutoOrderElementsObj = new AutoOrderElements(RqlConnectorObj, ContentClassGuid);
		});
	</script>
</head>
<body>
	<div id="processing">
	</div>
	<div id="delete-confirmation">
	</div>
	<div class="container">
		<div class="alert alert-block alert-info">
			<h4>Auto Order Elements</h4>
			Reorder all elements according to order of appearance in code
		</div>
		<div class="row-fluid">
			<div class="span6">
				<span class="label label-warning">All Elements</span>
				<div class="alert" id="all">
					loading...
				</div>
			</div>
			<div class="span6">
				<span class="label label-success">Order of Elements in Code</span>
				<div class="alert alert-success" id="code">
					loading...
				</div>
			</div>
		</div>
		<div class="form-actions">
			<div class="pull-right">
				<div class="btn btn-danger" id="reorderandclose">Reorder and Close</div>
				<div class="btn btn-success" id="reorder">Reorder</div>
			</div>
		</div>
	</div>
</body>
</html>