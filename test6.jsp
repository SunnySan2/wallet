﻿<%@ page language="java" pageEncoding="utf-8" contentType="text/html;charset=utf-8" %>
<%@ page trimDirectiveWhitespaces="true" %>

<%@page import="java.net.InetAddress" %>
<%@page import="org.json.simple.JSONObject" %>
<%@page import="org.json.simple.parser.JSONParser" %>
<%@page import="org.json.simple.parser.ParseException" %>
<%@page import="org.json.simple.JSONArray" %>
<%@page import="org.apache.commons.io.IOUtils" %>
<%@page import="java.util.*" %>


<%@ page import="com.blockcypher.context.BlockCypherContext"%>
<%@ page import="com.blockcypher.service.TransactionService"%>
<%@ page import="com.blockcypher.model.transaction.Transaction"%>
<%@ page import="com.blockcypher.model.transaction.intermediary.IntermediaryTransaction"%>
<%@ page import="com.blockcypher.utils.sign.SignUtils"%>
<%@ page import="com.blockcypher.utils.gson.GsonFactory"%>


<%@include file="00_constants.jsp"%>
<%@include file="00_utility.jsp"%>

<%
/***************輸入範例********************************************************
所有資料
http://127.0.0.1:8080/CHT/ajaxGetPaymentOrderList.jsp

單一資料
http://127.0.0.1:8080/CHT/ajaxGetPaymentOrderList.jsp?Payment_Order_ID=TX15011901DA55595D5898AD
*******************************************************************************/

/***************輸出範例********************************************************
*******************************************************************************/
%>

<%
request.setCharacterEncoding("utf-8");
response.setContentType("text/html;charset=utf-8");
response.setHeader("Pragma","no-cache"); 
response.setHeader("Cache-Control","no-cache"); 
response.setDateHeader("Expires", 0); 

out.clear();	//注意，一定要有out.clear();，要不然client端無法解析XML，會認為XML格式有問題

JSONObject	obj=new JSONObject();

/*********************開始做事吧*********************/

String sPublicKey			= nullToString(request.getParameter("PublicKey"), "");

writeLog("debug", "PublicKey= " + sPublicKey);

if (beEmpty(sPublicKey)){
	obj.put("resultCode", gcResultCodeParametersNotEnough);
	obj.put("resultText", gcResultTextParametersNotEnough);
	out.print(obj);
	out.flush();
	return;
}

String	sResponse	=	"";

// Choose API version / currency / network / token, here v1 on Bitcoin's testnet network
BlockCypherContext context = new BlockCypherContext("v1", "btc", "test3", "499a87caced64dbc835145453acb980a");

/*
String txHash = "09a228c6cf72989d81cbcd3a906dcb1d4b4a4c1d796537c34925feea1da2af35";
Transaction transaction = context.getTransactionService().getTransaction(txHash);
out.println("Transaction is confirmed? " + transaction.getConfirmed());
out.println("<p>Transaction fees are:     " + transaction.getFees());
*/

String txSkeleton = "";
String myPublicKey = "03A2916A004823D118B4D8ED261175FA186D9A3F99DF3CE7FAD37BD229E94DB77E";
String mySignature = "";

IntermediaryTransaction returnedObject = GsonFactory.getGson().fromJson(txSkeleton.toString(), IntermediaryTransaction.class);

        for (int i = 0; i < returnedObject.getTosign().size(); i++) {
            String toSign = returnedObject.getTosign().get(i);
            if (true) {
                out.println("<p>Pushing Pub key for input");
                returnedObject.addPubKeys(myPublicKey);
            }
            String signedString = mySignature;
            returnedObject.addSignature(signedString);
        }


out.println("<p>signedTx.toString: " + returnedObject.toString());

//IntermediaryTransaction returnedObject = GsonFactory.getGson().fromJson(unsignedTx.toString(), IntermediaryTransaction.class);

//Transaction tx = context.getTransactionService().sendTransaction(unsignedTx);


Transaction tx = context.getTransactionService().sendTransaction(returnedObject);
out.println("<p>Sent transaction: " + GsonFactory.getGsonPrettyPrint().toJson(tx));


//writeLog("debug", obj.toString());
%>

<%!

	//將 16 進位碼的字串轉為 byte array
	public static byte[] hex2Byte(String hexString) {
	        byte[] bytes = new byte[hexString.length() / 2];
	        for (int i=0 ; i<bytes.length ; i++)
	                bytes[i] = (byte) Integer.parseInt(hexString.substring(2 * i, 2 * i + 2), 16);
	        return bytes;
	}

    //取得 byte array 每個 byte 的 16 進位碼
    public static String byte2Hex(byte[] b) {
        String result = "";
        for (int i=0 ; i<b.length ; i++)
            result += Integer.toString( ( b[i] & 0xff ) + 0x100, 16).substring( 1 );
        return result;
    }


%>