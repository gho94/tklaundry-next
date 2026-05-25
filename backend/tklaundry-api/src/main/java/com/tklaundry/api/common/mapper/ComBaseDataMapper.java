package com.tklaundry.api.common.mapper;

import java.util.List;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

import com.tklaundry.api.common.model.ComBaseData;

@Mapper
public interface ComBaseDataMapper {

	List<ComBaseData> selectCodeListCte();

	int countByCodeId(@Param("codeId") String codeId);

	String selectLastCodeIdByHeader(@Param("header") String header);

	String selectMaxCodeId();

	List<String> selectCodeIdsByPCodeId(@Param("pCodeId") String pCodeId);

	int insertTblComBaseData(ComBaseData code);

	int updateTblComBaseData(ComBaseData code);

	int deleteTblComBaseData(@Param("codeId") String codeId);
}
