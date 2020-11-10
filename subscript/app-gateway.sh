#Argument Check
for i in "$@"
do
case $i in
    -g|--resource-group)
    RESOURCEGROUP="$2"
    shift 2
    ;;
    -l|--location)
    LOCATION="$2"
    shift 2
    ;;
    --nic-name)
    NIC="$2"
    shift 2
    ;;
    --vnet-name)
    VNETNAME="$2"
    shift 2
    ;;
    --subnet-name)
    SUBNETNAME="$2"
    shift 2
    ;;
    --public-ip)
    PIPNAME="$2"
    shift 2
    ;;
esac
done

if [ -z $RESOURCEGROUP ]; then
    echo "-g or --resource-group parameter is required ex) -g myResourceGroup"
    exit 1
elif [ -z $LOCATION ]; then
    echo "-l or --location parameter is required ex) -l koreacentral"
    exit 1
elif [ -z $NIC ]; then
    echo "--nic-name parameter is required ex) --nic-name myNic"
    exit 1
elif [ -z $VNETNAME ]; then
    echo "--vnet-name parameter is required ex) --vnet-name myVnet"
    exit 1
elif [ -z $SUBNETNAME ]; then
    echo "--subnet-name parameter is required ex) --subnet-name mySubnet"
    exit 1
elif [ -z $PIPNAME ]; then
    echo "--public-ip parameter is required ex) --public-ip myPIP"
    exit 1
fi

#Define variable name
AGName=mySimpleAppGateway

#Get Private Address
Niclist=$(az network nic list -g $RESOURCEGROUP --query "[?contains(name, '${NIC}')].[ipConfigurations[0].privateIpAddress]" -o tsv | tr '\r\n' ' ')


#Create Application Gateway
az network application-gateway create \
        --name $AGName \
        --location $LOCATION \
        --resource-group $RESOURCEGROUP \
        --capacity 2 \
        --sku Standard_v2 \
        --http-settings-cookie-based-affinity Enabled \
        --public-ip-address $PIPNAME \
        --vnet-name $VNETNAME \
        --subnet $SUBNETNAME \
        --servers $Niclist

#Update Application Gateway Setting
az network application-gateway probe create \
        -g $RESOURCEGROUP \
        --gateway-name $AGName \
        -n customProbe \
        --path / \
        --interval 15 \
        --threshold 3 \
        --timeout 10 \
        --protocol http \
        --host-name-from-http-settings true