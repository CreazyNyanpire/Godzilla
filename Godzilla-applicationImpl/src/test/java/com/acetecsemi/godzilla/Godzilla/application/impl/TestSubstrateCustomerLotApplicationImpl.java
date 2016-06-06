package com.acetecsemi.godzilla.Godzilla.application.impl;

import java.sql.SQLException;
import javax.inject.Inject;

import org.dayatang.querychannel.Page;
import org.dayatang.utils.Assert;
import org.junit.Before;
import org.junit.Test;
import org.openkoala.koala.util.KoalaBaseSpringTestCase;

import com.acetecsemi.godzilla.Godzilla.application.core.WaferCustomerLotApplication;
import com.acetecsemi.godzilla.Godzilla.application.dto.WaferCustomerLotDTO;


public class TestSubstrateCustomerLotApplicationImpl extends KoalaBaseSpringTestCase { 
  
    @Inject
	private WaferCustomerLotApplication WaferCustomerLotApplication;

    @Before
    public void before() throws SQLException {
//        Statement stmt  = null;
//        try{
//            String create = " CREATE TABLE `Employee` ( `id` int(11) DEFAULT NULL, `name` varchar(255) DEFAULT NULL, `age` varchar(255) DEFAULT NULL, `birthDate` date DEFAULT NULL, `gender` varchar(255) DEFAULT NULL )";
//            DataSource dataSource = InstanceFactory.getInstance(DataSource.class);
//            stmt = dataSource.getConnection().createStatement();
//            stmt.execute(create);
//        }catch(Exception e){
//        }finally{
//            stmt.close();
//        }
    }

    @Test
    public void test(){ 
    	
    	//WaferProcessDTO waferProcessDTO = waferProcessApplication.getWaferProcess((long)467);
    	//System.out.println(waferProcessDTO.getCurrStatus());
    	//Assert.a.isTrue("1".equals(waferProcessDTO.getCustomerCode()));
    	//dayAttendanceConfirmationCreateApplication.createDayAttendanceConfirmation(0, 5);
    	//monthlyAttendanceConfirmationCreateApplication.createMonthlyAttendanceConfirmation(2014, 5);
    	//Assert.isTrue(pages.getPageCount()==2);
    	//Assert.isTrue(pages.getStart()==10);
    	//Assert.isTrue(pages.getData().size()==1);
    } 
    
    @Test
    public void testQuery(){ 
    	
    	WaferCustomerLotDTO waferCustomerLotDTO = new WaferCustomerLotDTO();
    	//waferProcessDTO.setStationId((long) 1);
    	waferCustomerLotDTO.setCurrStatus("'Waiting','Hold','Received'");
    	Page<WaferCustomerLotDTO> res = WaferCustomerLotApplication.pageQueryWaferCustomerLot(waferCustomerLotDTO, 0, 10);
    	Assert.isTrue(res.getData().size() > 0);
    	//dayAttendanceConfirmationCreateApplication.createDayAttendanceConfirmation(0, 5);
    	//monthlyAttendanceConfirmationCreateApplication.createMonthlyAttendanceConfirmation(2014, 5);
    	//Assert.isTrue(pages.getPageCount()==2);
    	//Assert.isTrue(pages.getStart()==10);
    	//Assert.isTrue(pages.getData().size()==1);
    } 
 }