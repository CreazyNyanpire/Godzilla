package com.acetecsemi.godzilla.Godzilla.application.dto;

import java.util.Date;
import java.io.Serializable;

import org.springframework.format.annotation.DateTimeFormat;
import org.codehaus.jackson.map.annotate.JsonSerialize;
import org.openkoala.koala.springmvc.JsonDateSerializer;

public class EquipmentDTO implements Serializable {

	private Long id;

	private String area;

	private String status;

	private String description;

	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date lastModifyDate;

	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date lastModifyDateEnd;

	private String equipment;

	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date createDate;

	@DateTimeFormat(pattern = "yyyy-MM-dd")
	private Date createDateEnd;

	private String runlots;
	
	private String stationName;

	public void setArea(String area) {
		this.area = area;
	}

	public String getArea() {
		return this.area;
	}

	public void setStatus(String status) {
		this.status = status;
	}

	public String getStatus() {
		return this.status;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getDescription() {
		return this.description;
	}

	public void setLastModifyDate(Date lastModifyDate) {
		this.lastModifyDate = lastModifyDate;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getLastModifyDate() {
		return this.lastModifyDate;
	}

	public void setLastModifyDateEnd(Date lastModifyDateEnd) {
		this.lastModifyDateEnd = lastModifyDateEnd;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getLastModifyDateEnd() {
		return this.lastModifyDateEnd;
	}

	public void setEquipment(String equipment) {
		this.equipment = equipment;
	}

	public String getEquipment() {
		return this.equipment;
	}

	public void setCreateDate(Date createDate) {
		this.createDate = createDate;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreateDate() {
		return this.createDate;
	}

	public void setCreateDateEnd(Date createDateEnd) {
		this.createDateEnd = createDateEnd;
	}

	@JsonSerialize(using = JsonDateSerializer.class)
	public Date getCreateDateEnd() {
		return this.createDateEnd;
	}

	public String getRunlots() {
		return runlots;
	}

	public void setRunlots(String runlots) {
		this.runlots = runlots;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getId() {
		return id;
	}

	public String getStationName() {
		return stationName;
	}

	public void setStationName(String stationName) {
		this.stationName = stationName;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		EquipmentDTO other = (EquipmentDTO) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}
}