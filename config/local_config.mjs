// TODO: for real projects ALWAYS add this file to your .gitignore [!]

export const frontendPort = 9420;
export const psqlPort = 5432;
export const host = 'localhost';
export const mainDB = 'socialnetwork';
export const testDB = 'socialtest';
export const testUser = 'test_user';

export const config = {
    host: host,
    port: psqlPort,
    database: mainDB,
    user: 'migration_user',
    // this password is also in the user_setup.sql
    password: 'Changeme-123',
};

export const testConfig = {
    host: host,
    port: psqlPort,
    database: testDB,
    user: testUser,
    // this password is also in the test_setup.sql
    password: 'Changeme-123',
};