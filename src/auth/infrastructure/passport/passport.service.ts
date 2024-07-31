export const upsertGoogleUser = async (profile: any) => {
  console.log('Profile data:', profile);
  const user = {
    googleId: profile.id,
    name: profile.displayName,
    email: profile.emails[0].value,
  };
  console.log('User data:', user);
  return user;
};
