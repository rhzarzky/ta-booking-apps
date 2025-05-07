import api from "./api";
// list service api
export const getServiceApi = () => {
  return api.get("/service");
};
export const getServiceDetailApi = (id) => {
  return api.get("/service/" + id);
};
export const createServiceApi = () => {
  return api.post("/service");
};
export const editServiceApi = (id) => {
  return api.put("/service" + id);
};