import {getConnection} from '../database/connection';

export const getInstitucionesSICOP = async (req, res) =>{
    const pool =await getConnection();
    const result =await pool.request().query('EXEC REP_InstitucionesSICOP');
    console.log(result);
    res.json(result.recordset);
};