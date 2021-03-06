<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<title>晶圆库存</title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<%@ include file="/pages/common/header.jsp"%><!--引入权限系统该页面需无须引用header.jsp -->
<%@ page import="java.util.Date"%>
<% 
   String formId = "form_" + new Date().getTime();
   String gridId = "grid_" + new Date().getTime();
   String path = request.getContextPath()+request.getServletPath().substring(0,request.getServletPath().lastIndexOf("/")+1);
%>
<script type="text/javascript">
var grid;
var form;
var _dialog;
function requestParamToJson(paramArray)
{
	var jsonObj={};
	$(paramArray).each(function()
		{
			jsonObj[this.name]=this.value;
		});
	console.log(jsonObj);
	return jsonObj;
}
Array.prototype.debtcheck=Array.prototype.debtcheck ||function(id)
{
	for(var b in this){
		if(id==this[b]['lotId'])
			return false;
		}
	return true;
};
$(function (){
	/*
		grid改变绑定的单选框事件
	*/
	$("input[name='currStatus']").change(function() { 
		grid.unbind();
		var params={};
		if($(this).val()=="TotalWIP"){
			gridchange(grid);
			PageLoader.initGridPanel();
		}
		else if($(this).val()=="Waiting"){
			gridchange(grid);
			PageLoader.initGridPanel();
			grid.getGrid().searchCondition['currStatus']="'Waiting'";
			params['currStatus']="'Waiting'";
		}
		else if($(this).val()=="Running"){
			gridchange(grid);
			PageLoader.initGridPaneltwo();
			grid.getGrid().searchCondition['currStatus']="'Running'";
			params['currStatus']="'Running'";
		}
		else if($(this).val()=="OutSpec"){
			gridchange(grid);
			PageLoader.initGridPanelone();
			grid.getGrid().searchCondition['currStatus']="'Out-Spec'";
			params['currStatus']="'Out-Spec'";
		}
		else if($(this).val()=="CusDisp"){
			gridchange(grid);
			PageLoader.initGridPanelone();
			grid.getGrid().searchCondition['currStatus']="'Cus. Disp'";
			params['currStatus']="'Cus. Disp'";
		}else if($(this).val()=="EngDisp"){
			gridchange(grid);
			PageLoader.initGridPanelone();
			grid.getGrid().searchCondition['currStatus']="'Eng. Disp'";
			params['currStatus']="'Eng. Disp'";
		}else{
			gridchange(grid);
			PageLoader.initGridPanelone();
		}
		params['page']=0;
        params['page']=1000;
        params['stationId']=AlphaId;
        $.ajax({
			type : "POST",
			url : "${pageContext.request.contextPath}/WaferProcess/pageTotal.koala",
			data : params,
		}).done(function(result) {
			debugger;
			grid.next().children().children("#God_qtyTotle").text("Wafer #:"+result['waferTotal']+" | Qty:"+result['dieTotal']);
			grid.next().children().children("#God_batchTotle").text(result['countLot']);
		});
		waferInfoBind();
		HoldReasonSearchWafer();
	});
	$.get('${pageContext.request.contextPath}/WaferProcess/pageTotal.koala?stationId='+AlphaId).done(function(result){
		debugger;
		grid.next().children().children("#God_qtyTotle").text("Wafer #:"+result['waferTotal']+" | Qty:"+result['dieTotal']);
		grid.next().children().children("#God_batchTotle").text(result['countLot']);
	});
    grid = $("#<%=gridId%>");
    form = $("#<%=formId%>");
	PageLoader = {
	   //
	    initSearchPanel:function(){
	    },
	    initGridPanelone: function(){
	         var self = this;
	         var width = 100;
	         return grid.grid({
	                identity:"id",
	                buttons: [
								{content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Release</button>', action: 'Release'},
		                        {content: '<button class="btn btn-primary" type="button"><span class="glyphicon "><span style="margin-left:5px;">Change<span class="God_span_nbsp"/>Lot<span class="God_span_nbsp"/>Type</button>', action: 'Change_Lot_Type'},
		                        {content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Get<span class="God_span_nbsp"/>Traveler</button>', action: 'Get_Traveler'},
		                        {content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Get<span class="God_span_nbsp"/>Bom</button>', action: 'Get_Bom'},		                        
		                        {content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Lot<span class="God_span_nbsp"/>Summary</button>', action: 'Lot_Summary'},
	                    ],
	                //url:"${pageContext.request.contextPath}/WaferCompanyLot/pageJson.koala",
	                url:"${pageContext.request.contextPath}/WaferProcess/pageJson.koala",
	                columns: [
                        		  { title: 'Lot N.', name: 'lotNo', width: width},
			                      { title: 'Cus.Lot N.', name: 'customerLotNo', width: width},
			                      { title: 'Product Name', name: 'productName', width: width},
			                      { title: 'Part Name', name: 'partNumber', width: width},
			                      { title: 'Wafer #', name: 'waferQtyIn', width: width},
			                      { title: 'Qty', name: 'qtyIn', width: width},
			                      { title: 'Equipment', name: 'equipment', width: width},
			                      { title: 'Step', name: 'step', width: width},
			                      { title: 'Curr.Status', name: 'currStatus', width: width, render: function (rowdata, name, index){
			                    	  if(rowdata[name]=="Hold"||rowdata[name]=="Eng. Disp"||rowdata[name]=="Cus. Disp"||rowdata[name]=="Out-Spec")
			                   		  {
			                   		 	 var h = "<div id='currStatus"+rowdata['id']+"' style='color: #fff;background-color:red'>"+rowdata[name]+"</div>";
			                   		 	 return h;
			                   		  }
			                    	  else{
			                    		  return "<div id='currStatus"+rowdata['id']+"'>"+rowdata[name]+"</div>";
			                    	  } 
			                      }},
			                      { title: 'Lot Type', name: 'lotType', width: width},
			                      { title: 'Cust Order', name: 'customerOrder', width: width},
			                      { title: 'Entry Date', name: 'entryDate', width: 110},
			                      { title: 'Entry Time', name: 'entryTime', width: 110},
			                      { title: 'User', name: 'optUser', width: width},			                      
			                      { title: 'Hold Reason', name: 'holdReason', width: 100},
			                      { title: 'Inv Loc.', name: 'stockPos', width: width}
	                ]
	         }).on({
	                   'Change_Lot_Type': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Change_Lot_Type(indexs[0], $this);
	                    },
	                    'Release': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行Release'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行Release'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()=="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有非Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Release(indexs[0], $this);
	                    },
	                    'Get_Traveler': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录'
	                            })
	                            return;
	                        }
	                        
	                        window.open("/pages/WaferRunCard.jsp?id="+indexs[0]);
	                    },
	                    'Lot_Summary': function(event, data){
	                    	var indexs = data.data;
	                    	window.open("/pages/WaferLotSummary.jsp?id="+indexs[0]+"&stationId=" + AlphaId); 
	                    }
	                   
	         });
	    },
	    initGridPaneltwo: function(){
	         var self = this;
	         var width = 100;
	         return grid.grid({
	                identity:"id",
	                buttons: [
		                        {content: '<button class="btn btn-primary" type="button"><span class="glyphicon "><span style="margin-left:5px;">Abort<span class="God_span_nbsp"/>Step</button>', action: 'Abort_Step'},
		                        //{content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Track-Out</button>', action: 'Track_Out'},
		                        {content: '<button class="btn btn-danger" type="button"><span class="glyphicon "><span style="margin-left:5px;">Cus<span class="God_span_nbsp"/>Hold</button>', action: 'Cus_Hold'},
		                        {content: '<button class="btn btn-danger" type="button"><span class="glyphicon "><span style="margin-left:5px;">Eng<span class="God_span_nbsp"/>Hold</button>', action: 'Eng_Hold'},
		                        //{content: '<button class="btn btn-danger" type="button"><span class="glyphicon "><span style="margin-left:5px;">Future<span class="God_span_nbsp"/>Hold</button>', action: 'Future_Hold'},
		                        {content: '<button class="btn btn-primary" type="button"><span class="glyphicon "><span style="margin-left:5px;">Change<span class="God_span_nbsp"/>Lot<span class="God_span_nbsp"/>Type</button>', action: 'Change_Lot_Type'},
		                        {content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Get<span class="God_span_nbsp"/>Traveler</button>', action: 'Get_Traveler'},
		                        {content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Get<span class="God_span_nbsp"/>Bom</button>', action: 'Get_Bom'},		                        
		                        {content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Lot<span class="God_span_nbsp"/>Summary</button>', action: 'Lot_Summary'},
	                    ],
	                //url:"${pageContext.request.contextPath}/WaferCompanyLot/pageJson.koala",
	                url:"${pageContext.request.contextPath}/WaferProcess/pageJson.koala",
	                columns: [
                     		  { title: 'Lot N.', name: 'lotNo', width: width},
		                      { title: 'Cus.Lot N.', name: 'customerLotNo', width: width},
		                      { title: 'Product Name', name: 'productName', width: width},
		                      { title: 'Part Name', name: 'partNumber', width: width},
		                      { title: 'Wafer #', name: 'waferQtyIn', width: 60},
		                      { title: 'Qty', name: 'qtyIn', width: 50},
		                      { title: 'Equipment', name: 'equipment', width: width},
		                      { title: 'Step', name: 'step', width: width},
		                      { title: 'Curr.Status', name: 'currStatus', width: 90, render: function (rowdata, name, index){
		                    	  debugger;
		                    	  var h=null;
		                    	  $.ajax({
		                    			async:false,
		                    			url: '/WaferProcess/getFutureHoldReason/'+rowdata['id']+'.koala',
		                    			type: 'POST',
		                    			dataType: 'json',
		                    		})
		                    		.done(function(msg){
		                    			if(rowdata[name]=="Hold"||rowdata[name]=="Eng. Disp"||rowdata[name]=="Cus. Disp"||rowdata[name]=="Out-Spec")
				                   		  {
				                   		 	 h = "<div id='currStatus"+rowdata['id']+"' style='color: #fff;background-color:red'>"+rowdata[name]+"</div>";
				                   		  }
				                    	  else{
				                    		 h= "<div id='currStatus"+rowdata['id']+"' style='display:inline-block'>"+rowdata[name]+"</div>";
			                    			if(msg['data']['id']!=null)
		                    				{
		                    					h+='<span class="glyphicon glyphicon-time" name="'+rowdata['id']+'" style="float:right;cursor: pointer;">';
		                    				}
				                    	  }
		                    		});
		                    	  return h;
		                      }},
		                      { title: 'Lot Type', name: 'lotType', width: 70},
		                      { title: 'Cust Order', name: 'customerOrder', width: 90},
		                      { title: 'Entry Date', name: 'entryDate', width: 90},
		                      { title: 'Entry Time', name: 'entryTime', width: 90},
		                      { title: 'User', name: 'optUser', width: 70},		                      
		                      { title: 'Inv Loc.', name: 'stockPos', width: 90}
                ]
	         }).on({
	                   'Change_Lot_Type': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Change_Lot_Type(indexs[0], $this);
	                    },
	                    'Abort_Step': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行Abort'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行Abort'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Running")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Runing状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Abort_Step(indexs[0], $this);
	                    },
	                    'Track_Out': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行Track-Out'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行Track-Out'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Running")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Track_Out(indexs[0], $this);
	                    },
	                    'Cus_Hold': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                       self.Cus_Hold(indexs[0], $this);
	                    },
	                    'Eng_Hold': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                       self.Eng_Hold(indexs[0], $this);
	                    },
	                    'Future_Hold': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                       self.Future_Hold(indexs[0], $this);
	                    },
	                    'Get_Traveler': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录'
	                            })
	                            return;
	                        }
	                        
	                        window.open("/pages/WaferRunCard.jsp?id="+indexs[0]);
	                    },
	                    'Get_Bom': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录'
	                            })
	                            return;
	                        }
	                        window.open("/pages/WaferBomList.jsp?id="+indexs[0]);
	                    },
	                    'Lot_Summary': function(event, data){
	                    	var indexs = data.data;
	                    	window.open("/pages/WaferLotSummary.jsp?id="+indexs[0]+"&stationId=" + AlphaId); 
	                    }
	                   
	         });
	    },
	    initGridPanel: function(){
	         var self = this;
	         var width = 100;
	         return grid.grid({
	                identity:"id",
	                buttons: [
		                        {content: '<button class="btn btn-primary" type="button"><span class="glyphicon "><span style="margin-left:5px;">Change<span class="God_span_nbsp"/>Lot<span class="God_span_nbsp"/>Type</button>', action: 'Change_Lot_Type'},
		                        {content: '<button class="btn btn-primary" type="button"><span class="glyphicon "><span style="margin-left:5px;">Change<span class="God_span_nbsp"/>Loc.</button>', action: 'Change_Loc'},
		                        //{content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Track-In</button>', action: 'Track_In'},
		                        {content: '<button class="btn btn-danger" type="button"><span class="glyphicon "><span style="margin-left:5px;">Cus<span class="God_span_nbsp"/>Hold</button>', action: 'Cus_Hold'},
		                        {content: '<button class="btn btn-danger" type="button"><span class="glyphicon "><span style="margin-left:5px;">Eng<span class="God_span_nbsp"/>Hold</button>', action: 'Eng_Hold'},
		                       // {content: '<button class="btn btn-danger" type="button"><span class="glyphicon "><span style="margin-left:5px;">Fut<span class="God_span_nbsp"/>Hold</button>', action: 'Future_Hold'},
		                        {content: '<button class="btn btn-primary" type="button"><span class="glyphicon "><span style="margin-left:5px;">Change<span class="God_span_nbsp"/>P_N</button>', action: 'Change_P_N'},
		                        //{content: '<button class="btn btn-primary" type="button"><span class="glyphicon "><span style="margin-left:5px;">Split<span class="God_span_nbsp"/>Lot</button>', action: 'Split_Lot'},
		                        //{content: '<button class="btn btn-primary" type="button"><span class="glyphicon "><span style="margin-left:5px;">Merge<span class="God_span_nbsp"/>Lot</button>', action: 'Merge_Lot'},
		                        {content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Get<span class="God_span_nbsp"/>Traveler</button>', action: 'Get_Traveler'},
		                        {content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Get<span class="God_span_nbsp"/>Bom</button>', action: 'Get_Bom'},		                        
		                        {content: '<button class="btn btn-success" type="button"><span class="glyphicon "><span style="margin-left:5px;">Lot<span class="God_span_nbsp"/>Summary</button>', action: 'Lot_Summary'},
	                    ],
	                //url:"${pageContext.request.contextPath}/WaferCompanyLot/pageJson.koala",
	                url:"${pageContext.request.contextPath}/WaferProcess/pageJson.koala",
	                columns: [
                     		  { title: 'Lot N.', name: 'lotNo', width: width},
		                      { title: 'Cus.Lot N.', name: 'customerLotNo', width: width},
		                      { title: 'Product Name', name: 'productName', width: width},
		                      { title: 'Part Name', name: 'partNumber', width: width},
		                      { title: 'Wafer #', name: 'waferQtyIn', width: 60},
		                      { title: 'Qty', name: 'qtyIn', width: 50},
		                      { title: 'Equipment', name: 'equipment', width: width},
		                      { title: 'Step', name: 'step', width: width},
		                      { title: 'Curr.Status', name: 'currStatus', width: 90, render: function (rowdata, name, index){
		                    	  debugger;
		                    	  var h=null;
		                    	  $.ajax({
		                    			async:false,
		                    			url: '/WaferProcess/getFutureHoldReason/'+rowdata['id']+'.koala',
		                    			type: 'POST',
		                    			dataType: 'json',
		                    		})
		                    		.done(function(msg){
		                    			if(rowdata[name]=="Hold"||rowdata[name]=="Eng. Disp"||rowdata[name]=="Cus. Disp"||rowdata[name]=="Out-Spec")
				                   		  {
				                   		 	 h = "<div id='currStatus"+rowdata['id']+"' style='color: #fff;background-color:red'>"+rowdata[name]+"</div>";
				                   		  }
				                    	  else{
				                    		 h= "<div id='currStatus"+rowdata['id']+"' style='display:inline-block'>"+rowdata[name]+"</div>";
				                    	  } 
		                    			if(msg['data']['id']!=null&&rowdata[name]!="Hold"&&rowdata[name]!="Eng. Disp"&&rowdata[name]!="Cus. Disp"&&rowdata[name]!="Out-Spec")
	                    				{
	                    					h+='<span class="glyphicon glyphicon-time" name="'+rowdata['id']+'" style="float:right;cursor: pointer;">';
	                    				}
		                    		});
		                    	  return h;
		                      }},
		                      { title: 'Lot Type', name: 'lotType', width: 70},
		                      { title: 'Cust Order', name: 'customerOrder', width: 90},
		                      { title: 'Entry Date', name: 'entryDate', width: 90},
		                      { title: 'Entry Time', name: 'entryTime', width: 90},
		                      { title: 'User', name: 'optUser', width: 70},		                      
		                      { title: 'Inv Loc.', name: 'stockPos', width: 90}
                ]
	         }).on({
	                   'Change_Lot_Type': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Change_Lot_Type(indexs[0], $this);
	                    },
	                    'Change_Loc': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Change_Loc(indexs[0], $this);
	                    },
	                    'Track_In': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行Track-In'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行Track-In'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Track_In(indexs[0], $this);
	                    },
	                    'Cus_Hold': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Cus_Hold(indexs[0], $this);
	                    },
	                    'Eng_Hold': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Eng_Hold(indexs[0], $this);
	                    },
	                    'Future_Hold': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行hold'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Future_Hold(indexs[0], $this);
	                    },
	                    'Change_P_N': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行change'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Change_P_N(indexs[0], $this);
	                    },
	                    'Split_Lot': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录进行分批'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录进行分批'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Split_Lot(indexs[0], $this);
	                    },
	                    'Merge_Lot': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length < 2){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择至少两条记录进行合批'
	                            })
	                            return;
	                        }
	                        if($("#currStatus"+indexs[0]).text()!="Waiting")
	                    	{
		                    	$('body').message({
		                            type: 'error',
		                            content: '只有Waiting状态的批次才能执行该方法'
		                            });
		                    	return false;
	                    	}
	                       self.Merge_Lot(indexs, $this);
	                    },
	                    'Get_Traveler': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录'
	                            })
	                            return;
	                        }
	                        
	                        window.open("/pages/WaferRunCard.jsp?id="+indexs[0]);
	                    },
	                    'Get_Bom': function(event, data){
	                        var indexs = data.data;
	                        var $this = $(this);
	                        if(indexs.length == 0){
	                            $this.message({
	                                type: 'warning',
	                                content: '请选择一条记录'
	                            })
	                            return;
	                        }
	                        if(indexs.length > 1){
	                            $this.message({
	                                type: 'warning',
	                                content: '只能选择一条记录'
	                            })
	                            return;
	                        }
	                        window.open("/pages/WaferBomList.jsp?id="+indexs[0]);
	                    },
	                    'Lot_Summary': function(event, data){
	                    	var indexs = data.data;
	                    	window.open("/pages/WaferLotSummary.jsp?id="+indexs[0]+"&stationId=" + AlphaId); 
	                    }
	                   
	         });
	    },
	    Change_Lot_Type: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Change Lot Type</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferChangeLotType.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               debugger;
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                        dialog.find('#lotTypeIdID .dropdown-menu').bind("click",function(){
                    		var typearray=$("#lotTypeIdID input").val().split("|");
                    		$("#ActualLotTypeID").val(typearray[1]);
                    		});
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    var inobj={};
	                    inobj['id']=id;
	                    var Typearray=rs['lotTypeId'].split("|");
	                    inobj['lotTypeId']=Typearray[0];
	                    inobj['comments']=rs['comments'];
	                    delete rs['lotTypeId'];
	                    delete rs['comments'];
	                    rs['data']=inobj;
	  	          		var restring=JSON.stringify(rs);
	  	          		debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/changeLotType.koala', "data="+restring).done(function(result){
	                    	messagecheck(e,result,dialog);
	                    });
	                });
	        });
	    },
	    Change_Loc: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Change Loc</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferChangeLoc.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    var inobj={};
	                    inobj['id']=id;
	                    inobj['locationIds']=rs['locationIds'];
	                    inobj['comments']=rs['comments'];
	                    delete rs['locationIds'];
	                    delete rs['comments'];
	                    rs['data']=inobj;
	  	          		var restring=JSON.stringify(rs);
	  	          		debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/changeLocations.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }
	                        else if(result.result == 'fail'){
	                            dialog.find('.modal-content').message({
		                            type: 'error',
		                            content: "用户名或密码错误"
		                            });
		                        }
	                        else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    Release: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Release</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferRelease.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    var inobj={};
	                    inobj['id']=id;
	                    inobj['locationIds']=rs['locationIds'];
	                    inobj['comments']=rs['comments'];
	                    delete rs['locationIds'];
	                    delete rs['comments'];
	                    rs['data']=inobj;
	  	          		var restring=JSON.stringify(rs);
	  	          		debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/release.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }
	                        else if(result.result == 'fail'){
	                            dialog.find('.modal-content').message({
		                            type: 'error',
		                            content: "用户名或密码错误"
		                            });
		                        }
	                        else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    Track_In: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Track-In</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferTrackIn.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                      	//Track_In数据获取
                        $.ajax({
                        	async:false,
                        	url: '${pageContext.request.contextPath}/Station/findEquipments/'+AlphaId+'.koala',
                        	type: 'POST',
                        	dataType: 'json',
                        })
                        .done(function(msg) {
                        	debugger;
                        	msg=msg['data'];
                        	//var msg=[{'equipmentId':'1','equipment':'2008-04','description':'Insert the number of wafer Received','Status':'IDLE','runlots':'Lot001 RUN 10000'},{'equipmentId':'2','equipment':'2008-04','description':'Insert the number of wafer Received','Status':'IDLE','runlots':'Lot001 RUN 10000'},{'equipmentId':'3','equipment':'2008-04','description':'Insert the number of wafer Received','Status':'IDLE','runlots':'Lot001 RUN 10000'}];
                        	for(var i=0;i<msg.length;i++)
                        		{
                        			dialog.find("#God_Track_In_append").append("<tr><td><input type='radio' name='equipmentId' value='"+msg[i]['id']+"'></td><td style='text-align:left;'>"+msg[i]['equipment']+"</td><td style='text-align:left;'>"+msg[i]['discription']+"</td><td style='text-align:left;'>"+msg[i]['status']+"</td><td style='text-align:left;'>"+msg[i]['runlots']+"</td></tr>");
                        		}
                        });
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    var inobj={};
	                    if(rs['equipmentId'] === undefined){
                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: "请选择设备"
	                            });
                            return;
	                    }
	                    inobj['id']=id;
	                    inobj['comments']=rs['comments'];
	                    inobj['equipmentId']=rs['equipmentId'];
	                    rs['data']=inobj;
	                    delete rs['comments'];
	                    delete rs['equipmentId'];
	  	          		var restring=JSON.stringify(rs);
	  	          		debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/trackIn.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }
	                        else if(result.result == 'fail'){
	                            dialog.find('.modal-content').message({
		                            type: 'error',
		                            content: "用户名或密码错误"
		                            });
		                        }
	                        else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    Track_Out: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Track-Out</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal" id="God_cancel_split">取消</button><button type="button" class="btn btn-success" id="God_next_split">下一步</button><button type="button" class="btn btn-default" style="display:none" id="God_prev_split">上一步</button><button type="button" class="btn btn-success" style="display:none;" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferTrackOut.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               var debit={};
	               var waferDebit = [];
                   var directDebit = [];
                   var indirectDebit = [];
                   var waferIdLength=0;
                   var waferInfos=[];
	               dialog.find('.God_debit_lotNO').bind("blur",function(){
	            	   $.get( 'WaferInfo/getWaferInfo/' + funddatalistoption('God_debit_lotNumberList','God_debit_lotNO').attr('id') + '.koala').done(function(json){
	            		//var json={waferid:[{value:'acs123',id:'1',qty:'10'},{value:'9qe8yf98',id:'2',qty:'11'},{value:'e78fef',id:'3',qty:'12'},{value:'dq6w8d76',id:'4',qty:'13'}]};
	            		debugger;
	            		dialog.find('#God_debit_waferIdList select').empty();
	            		for(var i=0;i<json['data'].length;i++)
           				{
           					dialog.find('#God_debit_waferIdList select').append("<option qty='"+json['data'][i]['dieQty']+"' id='"+json['data'][i]['id']+"' value='"+json['data'][i]['waferId']+"'></option>");
           				}
	            	   });
	               });
	               
	               
	               //添加事件绑定
	               dialog.find('.God_debit_waferAdd').bind("click",function(){
	            	   		if($(".God_debit_waferId").val()==""||funddatalistoption('God_debit_waferIdList','God_debit_waferId').length=='0')
	            	   			{
	            	   				return false;
	            	   			}
	            	   		var json={lotId:funddatalistoption('God_debit_lotNumberList','God_debit_lotNO').attr('id'),waferId:funddatalistoption('God_debit_waferIdList','God_debit_waferId').attr('id'),qty:$(".God_debit_dieQty").val()}
	            	   		if(!waferDebit.debtcheck(funddatalistoption('God_debit_lotNumberList','God_debit_lotNO').attr('id')))
            	   			{return false;}
	            	   		waferDebit.push(json);
	            	  	 	$("#God_debit_viewTable").append("<tr><td>"+funddatalistoption('God_debit_lotNumberList','God_debit_lotNO').val()+"</td><td>"+funddatalistoption('God_debit_waferIdList','God_debit_waferId').val()+"</td><td>"+funddatalistoption('God_debit_waferIdList','God_debit_waferId').attr("qty")+"</td><td>"+$(".God_debit_dieQty").val()+"</td>");
	            	   });
	               dialog.find('.God_debit_directAdd').bind("click",function(){
			            	   if($(".God_debit_direct").val()==""||funddatalistoption('God_debit_directList','God_debit_direct').length=='0')
			       	   			{
			       	   				return false;
			       	   			}
	            	   		var json={lotId:funddatalistoption('God_debit_directList','God_debit_direct').attr('id'),qty:$(".God_debit_directQty").val()}
	            	   		if(!directDebit.debtcheck(funddatalistoption('God_debit_directList','God_debit_direct').attr('id')))
	            	   		{return false;}
	            	   		directDebit.push(json);
           	  	 			$("#God_debit_viewTable").append("<tr><td>"+funddatalistoption('God_debit_directList','God_debit_direct').val()+"</td><td> - </td><td>"+funddatalistoption('God_debit_directList','God_debit_direct').attr("qty")+"</td><td>"+$(".God_debit_directQty").val()+"</td>");
           	   	   });
	               dialog.find('.God_debit_indirectAdd').bind("click",function(){
			            	   if($(".God_debit_indirect").val()==""||funddatalistoption('God_debit_indirectList','God_debit_indirect').length=='0')
			       	   			{
			       	   				return false;
			       	   			}
	            	   		var json={lotId:funddatalistoption('God_debit_indirectList','God_debit_indirect').attr('id'),qty:$(".God_debit_indirectQty").val()}
	            	   		if(!indirectDebit.debtcheck(funddatalistoption('God_debit_indirectList','God_debit_indirect').attr('id')))
	            	   		{return false;}
	            	   		indirectDebit.push(json);
	           	  	 		$("#God_debit_viewTable").append("<tr><td>"+funddatalistoption('God_debit_indirectList','God_debit_indirect').val()+"</td><td> - </td><td>"+funddatalistoption('God_debit_indirectList','God_debit_indirect').attr("qty")+"</td><td>"+$(".God_debit_indirectQty").val()+"</td>");
	           	   	   });
	               //
	               
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                $.get( '${pageContext.request.contextPath}/ManufactureProcess/getMaterialDebitList/' + id + '.koala').done(function(json){
	                	debugger;
	                	json=json['data'];
	                	//var json=null;
	                	//var json={wafer:[{id:'1',value:'1111'},{id:'2',value:'2222'},{id:'3',value:'3333'}],direct:null,inderect:[{id:'1',value:'1111'},{id:'2',value:'2222'},{id:'3',value:'3333'}]};
	                	//var json={wafer:[{id:'12',value:'1111'},{id:'2',value:'2222'},{id:'3',value:'3333'}],direct:[{id:'1',value:'1111',qty:'10'},{id:'2',value:'2222',qty:'11'},{id:'3',value:'3333',qty:'12'}],indirect:[{id:'1',value:'1111',qty:'10'},{id:'2',value:'2222',qty:'11'},{id:'3',value:'3333',qty:'12'}]};
	                	if($.isEmptyObject(json))
	                		{
	                			dialog.find('.God_debit_cotent').remove();
	                		}
	                	else{
		                	if(json['wafer']!=null)
		                		{
		                			for(var i=0;i<json['wafer'].length;i++)
		                				{
		                					dialog.find('#God_debit_lotNumberList select').append("<option id='"+json['wafer'][i]['id']+"' value='"+json['wafer'][i]['value']+"'></option>");
		                				}
		                		}
		                	else{
		                		//dialog.find('.God_debit_wafer').remove();
		                	}
		                	if(json['direct']!=null)
	                		{
	                			for(var i=0;i<json['direct'].length;i++)
	                				{
	                					dialog.find('#God_debit_directList select').append("<option qty='"+json['direct'][i]['qty']+"' id='"+json['direct'][i]['id']+"' value='"+json['direct'][i]['value']+"'></option>");
	                				}
	                		}
	                		else{
	                			//dialog.find('.God_debit_Direct').remove();
	                		}
		                	if(json['indirect']!=null)
	                		{
	                			for(var i=0;i<json['indirect'].length;i++)
	                				{
	                					dialog.find('#God_debit_indirectList select').append("<option qty='"+json['direct'][i]['qty']+"' id='"+json['indirect'][i]['id']+"' value='"+json['indirect'][i]['value']+"'></option>");
	                				}
	                		}
	                		else{
	                			//dialog.find('.God_debit_InDirect').remove();
	                		}
	                	}
	                });
	                $.get('/WaferInfo/getWaferInfo/'+id+'.koala').done(function(json){
	    				debugger;
	    				json=json['data'];
	    				waferIdLength=json.length;
	    				var k=1;
	    				for(var i=0;i<json.length;i++)
	    					{
	    						dialog.find('#God_Track_In_append').append('<tr style="text-align:left;"><td style="vertical-align: middle;">'+k+'</td><td style="vertical-align: middle;" name="Wafer'+k+'" waferId='+json[i]['id']+'>'+json[i]['waferId']+'</td><td style="vertical-align: middle;" name="WaferQty'+k+'">'+json[i]['waferQty']+'</td><td><input name="goodDie'+k+'"type="text"></td><td><input name="defectiveDie'+k+'"type="text"></td><td class="rejectDes" style="display:none;"><input name="rejectDes'+k+'"type="text"></td></tr>');
	    						k++;
	    					}
	    				if(AlphaId=="405")
	    					{
	    						dialog.find(".rejectDes").css("display","block");
	    					}
	    			});
	                dialog.find('#God_next_split').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    waferInfos=[];
	                    for(var i=1;i<=waferIdLength;i++)
                    	{
	                    	debugger;
	                    	var gd=dialog.find('#God_Track_In_append input[name="goodDie'+i+'"]').val();
	                    	var dd=dialog.find('#God_Track_In_append input[name="defectiveDie'+i+'"]').val();
	                    	var wqty=dialog.find('#God_Track_In_append td[name="WaferQty'+i+'"]').text();
	                    	var des=dialog.find('#God_Track_In_append input[name="rejectDes'+i+'"]').val();
	                    	if((parseInt(gd)+parseInt(dd))>wqty){
	                    		dialog.find('.modal-content').message({
		                            type: 'error',
		                            content: "所填数量有误，请检查"
		                            });
	                    		return;
		                    }
	                    	var waferIdQty={};
	                    	if(des!="")
	                    		{
	                    			waferIdQty['rejectDes']=des;
	                    		}
	                    	waferIdQty['id']=dialog.find('#God_Track_In_append td[name="Wafer'+i+'"]').attr("waferId");
	                    	waferIdQty['GoodQtyOut']=gd;
	                    	waferIdQty['ScrapsQtyOut']=dd;
	                    	waferInfos.push(waferIdQty);
                    	}
	                    $(".God_trackOut_show").css("display","none");
	                    $(".God_split_hide").css("display","initial");
   	                    $("#God_cancel_split").css("display","none");
   	                    $("#save").css("display","initial");
   	                    $("#God_next_split").css("display","none");
   	                    $("#God_prev_split").css("display","initial");
   	                    $("#userNameID").attr("dataType","Require");
   	                 	$("#passwordID").attr("dataType","Require");
	                    });
	                dialog.find('#God_prev_split').on('click',{grid: grid}, function(e){
	                    //if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    $("#userNameID").attr("dataType","");
	                    $("#passwordID").attr("dataType","");
	                    $(".God_split_hide").css("display","none");
	                    $("#God_cancel_split").css("display","initial");
	                    $(".God_trackOut_show").css("display","initial");
	                    $("#save").css("display","none");
	                    $("#God_next_split").css("display","initial");
	                    $("#God_prev_split").css("display","none");
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    rs['data']={};
	                    rs['data']['waferInfos']=waferInfos;
	                    debit['waferDebit']=waferDebit;
	                    debit['directDebit']=directDebit;
	                    debit['indirectDebit']=indirectDebit;
	                    rs['data']['debit']=debit;
	  	          		var restring=JSON.stringify(rs);
	  	          		debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/nextProcess/' + id + '.koala', "data="+restring).done(function(result){
	                    	messagecheck(e,result,dialog);
	                    });
	                });
	        });
	    },
	    Abort_Step: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 32%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Abort Step</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('pages/inOut/UserInformation.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    var inobj={};
	                    inobj['id']=id;
	                    rs['data']=inobj;
	  	          		var restring=JSON.stringify(rs);
	  	          		debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/abortStep.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }
	                        else if(result.result == 'fail'){
	                            dialog.find('.modal-content').message({
		                            type: 'error',
		                            content: "用户名或密码错误"
		                            });
		                        }
	                        else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    Cus_Hold: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Cus Hold</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferCusHold.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    var inobj={};
	                    inobj['id']=id;
	                    inobj['holdCode']="";
	                    inobj['holdCodeId']=rs['holdCodeId'];
	                    inobj['comments']=rs['comments'];
	                    delete rs['holdCode'];
	                    delete rs['comments'];
	                    delete rs['holdCodeId'];
	                    rs['data']=inobj;
	  	          		var restring=JSON.stringify(rs);
	  	          		debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/hold.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }
	                        else if(result.result == 'fail'){
	                            dialog.find('.modal-content').message({
		                            type: 'error',
		                            content: "用户名或密码错误"
		                            });
		                        }
	                        else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    Eng_Hold: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Eng Hold</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferEngHold.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    var inobj={};
	                    inobj['id']=id;
	                    inobj['holdCode']="";
	                    inobj['holdCodeId']=rs['holdCodeId'];
	                    inobj['comments']=rs['comments'];
	                    delete rs['holdCode'];
	                    delete rs['comments'];
	                    delete rs['holdCodeId'];
	                    rs['data']=inobj;
	  	          		var restring=JSON.stringify(rs);
	  	          	    debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/hold.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }
	                        else if(result.result == 'fail'){
	                            dialog.find('.modal-content').message({
		                            type: 'error',
		                            content: "用户名或密码错误"
		                            });
		                        }
	                        else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    Future_Hold: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Future Hold</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferFutureHold.jsp?id='+id).done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    var inobj={};
	                    inobj['id']=id;
	                    inobj['holdCode']="";
	                    inobj['holdCodeId']=rs['holdCodeId'];
	                    inobj['futureStationId']=rs['futureStationId'];
	                    inobj['comments']=rs['comments'];
	                    delete rs['holdCode'];
	                    delete rs['comments'];
	                    delete rs['futureStationId'];
	                    delete rs['holdCodeId'];
	                    rs['data']=inobj;
	  	          		var restring=JSON.stringify(rs);
	  	          	    debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/future.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }else if(result.result == 'fail'){
	                            dialog.find('.modal-content').message({
		                            type: 'error',
		                            content: "用户名或密码错误"
		                            });
		                    }else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    Change_P_N: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Change P_N</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferChange_P_N.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    rs['id']=id;
	  	          		var restring=JSON.stringify(rs);
	  	          		debugger;
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/update.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    Split_Lot: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">分批</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal" id="God_cancel_split">取消</button><button type="button" class="btn btn-success" id="God_next_split">下一步</button><button type="button" class="btn btn-default" style="display:none" id="God_prev_split">上一步</button><button type="button" class="btn btn-success" style="display:none;" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferSplitLot.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.ajax({
	               		async:false,
	               		url: '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala',
	               		type: 'GET',
	               		dataType: 'json',
	               		}).done(function(json){
		            	   debugger;
	                       json = json.data;
	                        var elm;
	                        for(var index in json){
	                            elm = dialog.find('#'+ index + 'ID');
	                            if(elm.hasClass('select')){
	                                elm.setValue(json[index]);
	                            }else{
	                                elm.text(json[index]);
	                            }
	                        }
	                        $.ajax({
	                    		async:false,
	                    		url: '${pageContext.request.contextPath}/WaferInfo/getWaferInfo/'+id+'.koala',
	                    		type: 'GET',
	                    		dataType: 'json',
	                    	})
	                    	.done(function(json){
	            				debugger;
	            				json=json['data'];
	            				for(var i=0;i<json.length;i++)
	            					{
                        				dialog.find('#my-select').append("<option value='"+json[i]['id']+"'>"+json[i]['waferId']+" ("+json[i]['dieQty']+")</option>");
	            					}
	            				dialog.find('#my-select').multiSelect();
	                       	});
	                	});
		                dialog.modal({
		                    keyboard:false
		                }).on({
		                    'hidden.bs.modal': function(){
		                        $(this).remove();
		                    }
		                });
		                dialog.find('#God_next_split').on('click',{grid: grid}, function(e){
		                    if(!Validator.Validate(dialog.find('form')[0],3))return;
		                    var rs=requestParamToJson(dialog.find('form').serializeArray());
		                    var inobj={};
		                    var waferinfo=[];
		                    inobj['id']=id;
		                    inobj['waferQty']=dialog.find(".ms-selection .ms-selected span").length;
		                    var dieqty=0;
		                    for(var j=0;j<dialog.find(".ms-selection .ms-selected span").length;j++)
		                    	{
		                    		dieqty+=parseInt(dialog.find(".ms-selection .ms-selected span").eq(j).text().split(" (")[1].substring(0,dialog.find(".ms-selection .ms-selected span").eq(j).text().split(" (")[1].length-1));
		                    		waferinfo.push(dialog.find(".ms-selection .ms-selected span").eq(j).text().split(" (")[0]);
		                    	}
		                    inobj['dieQty']=dieqty;
		                    inobj['comments']=rs['comments'];
		                    inobj['locationIds']=rs['locationIds'];
		                    inobj['waferinfo']=waferinfo;
		                    rs['data']=inobj;
		                    delete rs['comments'];
		                    delete rs['dieQty'];
		                    delete rs['waferQty'];
		                    delete rs['locationIds'];
		                    debugger;
		  	          		var restring=JSON.stringify(rs);
	   	                    $.post( '${pageContext.request.contextPath}/WaferProcess/Process/getSplit.koala',"data="+restring).done(function(json){
	       	            	   debugger;
	       	            	   $(".God_split_hide").show();
	                              json = json.splitDate;
	                               var elm;
	                               for(var i=0;i<json.length;i++)
	                           	{
	   	                        	for(var index in json[i]){
	   	                                elm = dialog.find('#'+ index + 'ID'+i);
	   	                                if(elm.hasClass('select')){
	   	                                    elm.setValue(json[i][index]);
	   	                                }else{
	   	                                    elm.text(json[i][index]);
	   	                                }
	   	                            }                    	
	                           	}
	                       	});
	   	                    $("#God_cancel_split").css("display","none");
	   	                    $("#save").css("display","initial");
	   	                    $("#God_next_split").css("display","none");
	   	                    $("#God_prev_split").css("display","initial");
		                    });
		                dialog.find('#God_prev_split').on('click',{grid: grid}, function(e){
		                    if(!Validator.Validate(dialog.find('form')[0],3))return;
		                    $(".God_split_hide").css("display","none");
		                    $("#God_cancel_split").css("display","initial");
		                    $("#save").css("display","none");
		                    $("#God_next_split").css("display","initial");
		                    $("#God_prev_split").css("display","none");
		                });
		                dialog.find('#save').on('click',{grid: grid}, function(e){
		                    if(!Validator.Validate(dialog.find('form')[0],3))return;
		                    var rs=requestParamToJson(dialog.find('form').serializeArray());
		                    var inobj={};
		                    var waferinfo=[];
		                    inobj['id']=id;
		                    inobj['waferQty']=dialog.find(".ms-selection .ms-selected span").length;
		                    var dieqty=0;
		                    for(var j=0;j<dialog.find(".ms-selection .ms-selected span").length;j++)
		                    	{
		                    		dieqty+=parseInt(dialog.find(".ms-selection .ms-selected span").eq(j).text().split(" (")[1].substring(0,dialog.find(".ms-selection .ms-selected span").eq(j).text().split(" (")[1].length-1));
		                    		waferinfo.push(dialog.find(".ms-selection .ms-selected span").eq(j).text().split(" (")[0]);
		                    	}
		                    inobj['dieQty']=dieqty;
		                    inobj['comments']=rs['comments'];
		                    inobj['locationIds']=rs['locationIds'];
		                    inobj['waferinfo']=waferinfo;
		                    rs['data']=inobj;
		                    delete rs['comments'];
		                    delete rs['dieQty'];
		                    delete rs['waferQty'];
		                    delete rs['locationIds'];
		  	          		var restring=JSON.stringify(rs);
		                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/split.koala', "data="+restring).done(function(result){
		                        if(result.result == 'success'){
		                            dialog.modal('hide');
		                            e.data.grid.data('koala.grid').refresh();
		                            e.data.grid.message({
		                            type: 'success',
		                            content: '分批成功'
		                            });
		                        }
		                        else if(result.result == 'fail'){
		                        	dialog.find('.modal-content').message({
			                            type: 'error',
			                            content: '用户名或密码错误'
			                            });
		                        } 	
		                        else{
		                            dialog.find('.modal-content').message({
		                            type: 'error',
		                            content: result.actionError
		                            });
		                        }
		                    });
		                });
		        });
		    },
	    Merge_Lot: function(ids, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">合批</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferMergeLot.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               debugger;
	               $.ajax({
		           		async:false,
		           		url: '${pageContext.request.contextPath}/WaferProcess/Process/getProcesses.koala',
		           		data:{'ids':ids.join(',')},
		           		type: 'POST',
		           		dataType: 'json',
		           		}).done(function(json){
	            	   debugger;
	            	   if(json.mergeData===null)
            		   {
	            		   $('body').message({
	                            type: 'error',
	                            content: '批次信息不一致无法合批'
	                            });
	            		   dialog.find('#save').hide();
	            		   return;
            		   }
                       json1 = json.data;
                       var elm;
                       for(var i=0;i<json1.length;i++)
                       	{
	                        	for(var index in json1[i]){
	                                elm = dialog.find('#'+ index + 'ID'+i);
	                                if(elm.hasClass('select')){
	                                    elm.setValue(json1[i][index]);
	                                }else{
	                                    elm.text(json1[i][index]);
	                                }
	                            }                    	
                       	}
                        json = json.mergeData;
                       	for(var index in json){
                               elm = dialog.find('#'+ index + 'ID2');
                               if(elm.hasClass('select')){
                                   elm.setValue(json[index]);
                               }else{
                                   elm.text(json[index]);
                               }
                           }
                       	dialog.modal({
    	                    keyboard:false
    	                }).on({
    	                    'hidden.bs.modal': function(){
    	                        $(this).remove();
    	                    }
    	                });
                	});
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    rs['ids']=ids.join(',');
	  	          		var restring=JSON.stringify(rs);
	                    $.post('${pageContext.request.contextPath}/WaferProcess/Process/merge.koala', "data="+restring).done(function(result){
	                    	messagecheck(e,result,dialog);
	                    });
	                });
	        });
	    },
	    Get_Traveler: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">发料</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferGetTraveler.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    rs['id']=id;
	  	          		var restring=JSON.stringify(rs);
	  	          		debugger;
	                    $.post('${pageContext.request.contextPath}/WaferCompanyLot/update.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    Get_Bom: function(id, grid){
	        var self = this;
	        var dialog = $('<div class="modal fade"><div style="width: 100%;" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">发料</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">取消</button><button type="button" class="btn btn-success" id="save">提交</button></div></div></div></div>');
	        $.get('<%=path%>/WaferGetBom.jsp').done(function(html){
	               dialog.find('.modal-body').html(html);
	               self.initPage(dialog.find('form'));
	               $.get( '${pageContext.request.contextPath}/WaferProcess/get/' + id + '.koala').done(function(json){
                       json = json.data;
                        var elm;
                        for(var index in json){
                            elm = dialog.find('#'+ index + 'ID');
                            if(elm.hasClass('select')){
                                elm.setValue(json[index]);
                            }else{
                                elm.text(json[index]);
                            }
                        }
                	});
	                dialog.modal({
	                    keyboard:false
	                }).on({
	                    'hidden.bs.modal': function(){
	                        $(this).remove();
	                    }
	                });
	                dialog.find('#save').on('click',{grid: grid}, function(e){
	                    if(!Validator.Validate(dialog.find('form')[0],3))return;
	                    var rs=requestParamToJson(dialog.find('form').serializeArray());
	                    rs['id']=id;
	  	          		var restring=JSON.stringify(rs);
	                    $.post('${pageContext.request.contextPath}/WaferCompanyLot/update.koala', "data="+restring).done(function(result){
	                        if(result.result == 'success'){
	                            dialog.modal('hide');
	                            e.data.grid.data('koala.grid').refresh();
	                            e.data.grid.message({
	                            type: 'success',
	                            content: '保存成功'
	                            });
	                        }else{
	                            dialog.find('.modal-content').message({
	                            type: 'error',
	                            content: result.actionError
	                            });
	                        }
	                    });
	                });
	        });
	    },
	    initPage: function(form){
	              form.find('.form_datetime').datetimepicker({
	                   language: 'zh-CN',
	                   format: "yyyy-mm-dd",
	                   autoclose: true,
	                   todayBtn: true,
	                   minView: 2,
	                   pickerPosition: 'bottom-left'
	               }).datetimepicker('setDate', new Date());//加载日期选择器
	               form.find('.select').each(function(){
	                    var select = $(this);
	                    var idAttr = select.attr('id');
	                    select.select({
	                        title: '请选择',
	                        contents: selectItems[idAttr]
	                    }).on('change', function(){
	                        form.find('#'+ idAttr + '_').val($(this).getValue());
	                    });
	               });
	    }
	}
	PageLoader.initSearchPanel();
	PageLoader.initGridPanel();
	//点击lotNo查看wafer信息时间绑定
	$(".table").bind("mouseover", function(){
		$("td[index='1']").unbind();
		$("td[index='1']").bind('mouseover', function(e){
			$(this).css("color","#0094c8");
		});
		$("td[index='1']").bind('mouseout', function(e){
			$(this).css("color","#333");
		});
		$("td[index='1']").css("cursor","pointer");
		$("td[index='1']").bind('click', function(e){
			debugger;
			var dialog = $('<div class="modal fade"><div style="width:800px" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Wafer Information</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">关闭</button></div></div></div></div>');
			dialog.modal({
                keyboard:false
            }).on({
                'hidden.bs.modal': function(){
                    $(this).remove();
                }
            });
			var id=$(this).parent().children().children('div').attr("data-value");
			dialog.find('.modal-body').html('<form class="form-horizontal"></form>');
			$.get('${pageContext.request.contextPath}/WaferInfo/getWaferInfo/'+id+'.koala').done(function(json){
				debugger;
				json=json['data'];
				var k=1;
				for(var i=0;i<json.length;i++)
					{
						dialog.find('.form-horizontal').append('<div class="form-group"><label class="col-lg-2 control-label">Wafer'+k+':</label><div class="col-lg-5"><input name="Wafer'+json[i]['waferNumber']+'" style="display:inline; width:94%;" class="form-control" Placeholder="Input WaferId..." type="text"/></div><div class="col-lg-4"><input name="WaferQty'+json[i]['waferNumber']+'" style="display:inline; width:94%;" class="form-control" Placeholder="Input WaferQty..." type="text" /></div>');
						k++;
					}
	            var elm;
	            for(var i=0;i<=json.length;i++){
	                elm = dialog.find("input[name='Wafer"+json[i]['waferNumber']+"']");
	                elm.val(json[i]['waferId']);
	                elm = dialog.find("input[name='WaferQty"+json[i]['waferNumber']+"']");
	                elm.val(json[i]['dieQty']);
	            }
			});
          });
		$("div[id^='currStatus']").unbind();
		for(var i=0;i<$("div[id^='currStatus']").length;i++)
		{
			if($("div[id^='currStatus']").eq(i).attr("style")!=undefined&&$("div[id^='currStatus']").eq(i).text()!="Waiting")
				{
					$("div[id^='currStatus']").eq(i).css("cursor","pointer");
					$("div[id^='currStatus']").eq(i).bind('click', function(e){
						debugger;
						var dialog = $('<div class="modal fade"><div style="width:800px" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Hold Reason</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">关闭</button></div></div></div></div>');
						dialog.modal({
			                keyboard:false
			            }).on({
			                'hidden.bs.modal': function(){
			                    $(this).remove();
			                }
			            });
						var id=$(this).attr('id').replace(/[^0-9]/ig,"");
						dialog.find('.modal-body').html('<form class="form-horizontal"></form>');
						$.get('${pageContext.request.contextPath}/WaferProcess/getHoldReason/'+id+'.koala').done(function(json){
							debugger;
							json=json['data'];
							dialog.find('.form-horizontal').append('<div class="form-group"><label class="col-lg-2 control-label">Reason:</label><div class="col-lg-9"></div>');
							dialog.find(".col-lg-9").text(json['comments']);
						});
					});
				}
		}
		//获取futureHold的信息
		$('.glyphicon-time').unbind();
		$('.glyphicon-time').bind('click', function(e){
			debugger;
			var dialog = $('<div class="modal fade"><div style="width:800px" class="modal-dialog"><div class="modal-content"><div class="modal-header"><button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button><h4 class="modal-title">Future Hold Search</h4></div><div class="modal-body"><p>One fine body&hellip;</p></div><div class="modal-footer"><button type="button" class="btn btn-default" data-dismiss="modal">关闭</button></div></div></div></div>');
			dialog.modal({
	            keyboard:false
	        }).on({
	            'hidden.bs.modal': function(){
	                $(this).remove();
	            }
	        });
			dialog.find('.modal-body').html('<form class="form-horizontal"></form>');
			$.get('/WaferProcess/getFutureHoldReason/'+$(this).attr('name')+'.koala').done(function(json){
				debugger;
				json=json['data'];
				dialog.find('.form-horizontal').append('<div class="form-group"><label class="col-lg-2 control-label">Reason:</label><div class="col-lg-9 text1"></div>');
				dialog.find(".text1").text(json['comments']);
				dialog.find('.form-horizontal').append('<div class="form-group"><label class="col-lg-2 control-label ">Hold Code:</label><div class="col-lg-9 text2"></div>');
				dialog.find(".text2").text(json['holdCode']);
				dialog.find('.form-horizontal').append('<div class="form-group"><label class="col-lg-2 control-label ">Hold Station:</label><div class="col-lg-9 text3"></div>');
				dialog.find(".text3").text(json['futureStationName']);
				dialog.find('.form-horizontal').append('<div class="form-group"><label class="col-lg-2 control-label ">Hold Time:</label><div class="col-lg-9 text4"></div>');
				dialog.find(".text4").text(json['createDate']);
				dialog.find('.form-horizontal').append('<div class="form-group"><label class="col-lg-2 control-label ">Name:</label><div class="col-lg-9 text5"></div>');
				dialog.find(".text5").text(json['optName']);
			});
		});
		/*table排序查询demo
		******************************************************************************************************
		$('th').unbind();
		$('th').bind('hover',function(){$(this).css('cursor','pointer');$(this).css('color','#555');});
		$('th').bind('click',function(){gridchange(grid);
		PageLoader.initGridPanel();
		grid.getGrid().searchCondition['currStatus']="'Waiting'";});
		******************************************************************************************************
		*/
	});
	
	form.find('#search').on('click', function(){
        if(!Validator.Validate(document.getElementById("<%=formId%>"),3))return;
        var params = {};
        var status='';
        var type='';
        form.find('input').each(function(){
            var $this = $(this);
            if($this.attr("checked")=='checked')
            	{
            		if($this.attr("class")=='currstatus')
           			{
           				status+="'"+$this.val()+"',";
           			}
            		if($this.attr("class")=='type')
        			{
            			type+=$this.val()+",";
        			}
            		
            	}
            var name = $this.attr('name');
            if(name){
                params[name] = $this.val();
            }
        });
        status=status.substring(0,status.length-1);
        type=type.substring(0,type.length-1);
        //params['currStatus']=status;
        delete params['currStatus'];
        params['LotType']=type;
        debugger;
        grid.getGrid().search(params);
        params['page']=0;
        params['page']=1000;
        params['stationId']=AlphaId;
        $.ajax({
			type : "POST",
			url : "${pageContext.request.contextPath}/WaferProcess/pageTotal.koala",
			data : params,
		}).done(function(result) {
			debugger;
			grid.next().children().children("#God_qtyTotle").text("Wafer #:"+result['waferTotal']+" | Qty:"+result['dieTotal']);
			grid.next().children().children("#God_batchTotle").text(result['countLot']);
		});
    });
});
</script>
</head>
<body>
<div style="width:98%;margin-right:auto; margin-left:auto; padding-top: 15px;">
<!-- search form -->
<form name=<%=formId%> id=<%=formId%> target="_self" class="form-horizontal">
<input type="hidden" name="page" value="0">
<input type="hidden" name="pagesize" value="10">
<a style="position: absolute;right: 0;margin-right: 3%;"class="btn btn-primary" href="/pages/core/Equipment-list.jsp" target="_blank" >设备状态查询维护</a>
<table border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>
       	<div class="form-group God_Status">
    		<label class="control-label" style="width:100px;float:left;text-align:left;padding-left:5%;">Status:&nbsp;</label>
            <div style="margin-left:15px;float:left;">
            	<input name="currStatus" class="currstatus" type="radio" value="Waiting" id="currStatusWaitingID"  />
            	<span>Waiting</span>
            	<input name="currStatus" class="currstatus" type="radio" value="Running" id="currStatusRuningID"  />
            	<span>Running</span>
            	<input name="currStatus"  class="currstatus" type="radio" value="OutSpec"  id="currStatusOutSpecID"  />
            	<span>Out-Spec</span>
            	<input name="currStatus" class="currstatus" type="radio" value="CusDisp"  id="currStatusCusDispID"  />
            	<span>Cus.Disp</span>
            	<input name="currStatus" class="currstatus" type="radio" value="EngDisp" id="currStatusEngDispID"  />
            	<span>Eng.Disp</span>
            	<input name="currStatus" class="currstatus" type="radio" value="TotalWIP"  id="currStatusTotalWIPID"  />
            	<span>Total WIP</span>
        	</div>
        	<label class="control-label" style="width:100px;float:left;">Type:&nbsp;</label>
            <div style="margin-left:15px;float:left;">
            	<input name=typeNP class="type" type="checkbox" value="822" id="typeNPID"  />
            	<span>NP</span>
            	<input name=typeEng class="type" type="checkbox" value="824" id="typeEngID"  />
            	<span>Eng</span>
            	<input name=typeSWR class="type" type="checkbox" value="826"  id="typeSWRID"  />
            	<span>Cus.SWR</span>
            	<input name=typeISWR class="type" type="checkbox" value="828"  id="typeISWRID"  />
            	<span>Intern.SWR</span>
        	</div>
    	</div>
          <div class="form-group">
                      <label class="control-label" style="width:100px;float:left;text-align:left;padding-left:5%;">Lot No:&nbsp;</label>
            <div style="margin-left:15px;float:left;">
            <input name="lotNo" class="form-control" type="text" style="width:180px;" id="lotNoID" />
        </div>
                          <label class="control-label" style="width:100px;float:left;">Cus.Lot No:&nbsp;</label>
            <div style="margin-left:15px;float:left;">
            <input name="customerLotNo" class="form-control" type="text" style="width:180px;" id="customerLotNoID"  />
        </div>
            </div>
                </td>
       <td style="vertical-align: bottom;"><button id="search" type="button" class="btn btn-primary"><span class="glyphicon glyphicon-search"></span>&nbsp;Search</button></td>
  </tr>
</table>	
</form>
<!-- grid -->
<div id=<%=gridId%>></div>
<div id="God_search"><div style="display: inline-block;width: 300px;margin-left: 1%;"><span>批次统计：</span><span id="God_batchTotle"></span></div><div style="display: inline-block;width: 300px;margin-left: 5%;"><span>数量统计：</span><span id="God_qtyTotle"></span></div></div>
</div>
</body>
</html>