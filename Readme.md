Nstallation on EC2 Ubuntu :

Update and Install Dependencies:
sudo apt update


Install Node.js and npm:
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

Verify installation:
node -v
npm -v

Install PostgreSQL (optional):
sudo apt install -y postgresql postgresql-contrib

Start and enable PostgreSQL service:
sudo systemctl start postgresql
sudo systemctl enable postgresql

Install Yarn:
npm install -g yarn

Run the strapi project installation script and create a Strapi account:
npx create-strapi-app@latest my-strapi-project --quickstart

