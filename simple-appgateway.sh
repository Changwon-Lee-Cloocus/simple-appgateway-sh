#Define variable name
Location=koreacentral
RGName=mySimpleAGRG
VnetName=mySimpleAGVnet
SubNetName=mySimpleAGSubnet
BackendSubNetName=mySimpleAGBackSubnet
PIPName=mySimpleAGPIP
VMQuantity=2

#ResourceGroup Create
az group create -n $RGName -l $Location

#NetWorkResource Create
az network vnet create \
        -g $RGName \
        -n $VnetName \
        -l $Location \
        --address-prefix 10.0.0.0/16 \
        --subnet-name $SubNetName \
        --subnet-prefix 10.0.1.0/24

az network vnet subnet create \
        --name $BackendSubNetName \
        --resource-group $RGName \
        --vnet-name $VnetName   \
        --address-prefix 10.0.2.0/24

az network public-ip create \
        --resource-group $RGName \
        --name $PIPName \
        --allocation-method Static \
        --sku Standard

#create vm
for i in `seq 1 $VMQuantity`; do
        az network nic create \
                --resource-group $RGName \
                --name myNic$i \
                --vnet-name $VnetName \
                --subnet $BackendSubNetName

        az vm create \
                --resource-group $RGName \
                --name myVM$i \
                --nics myNic$i \
                --image UbuntuLTS \
                --admin-username azureuser \
                --generate-ssh-keys \
                --custom-data cloud-init.txt
done

#Create AppGateway
bash ./subscript/app-gateway.sh -g $RGName -l $Location --vnet-name $VnetName --subnet-name $SubNetName --public-ip $PIPName --nic-name myNic